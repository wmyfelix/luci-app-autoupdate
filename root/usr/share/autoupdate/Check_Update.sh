#!/bin/bash
# https://github.com/Hyy2001X/AutoBuild-Actions
# AutoBuild Module by Hyy2001

rm -f /tmp/cloud_version
if [ ! -f /bin/AutoUpdate.sh ];then
	echo "未检测到 /bin/AutoUpdate.sh" > /tmp/cloud_version
	exit
fi
[ -f /etc/openwrt_info ] && source /etc/openwrt_info || {
	echo -e "\n未检测到 /etc/openwrt/info,无法运行更新程序!"
	exit
}
[[ -z "${DEFAULT_Device}" ]] && DEFAULT_Device="$(jsonfilter -e '@.model.id' < "/etc/board.json" | tr ',' '_')"
Github_Tags=$(/bin/AutoUpdate.sh -tag)
[[ -z "Github_Tags" ]]&& exit
curl -SsL ${Github_Tags} -o /tmp/Github_Tags
case ${DEFAULT_Device} in
x86_64)
	if [ -d /sys/firmware/efi ];then
		Firmware_SFX="-UEFI.${Firmware_Type}"
		BOOT_Type="-UEFI"
	else
		Firmware_SFX="-Legacy.${Firmware_Type}"
		BOOT_Type="-Legacy"
	fi
;;
*)
	Firmware_SFX=".${Firmware_Type}"
	BOOT_Type=""
;;
esac
Cloud_Version="$(cat /tmp/Github_Tags | egrep -o "${DEFAULT_Device}-R[0-9]+.[0-9]+.[0-9]+.[0-9]+-squashfs-sysupgrade${Firmware_SFX}" | awk 'END {print}' | egrep -o 'R[0-9]+.[0-9]+.[0-9]+.[0-9]+')"
if [[ ! -z "${Cloud_Version}" ]];then
	if [[ "${CURRENT_Version}" == "${Cloud_Version}" ]];then
		Checked_Type="已是最新"
	else
		Checked_Type="可更新"
	fi
	echo "${Cloud_Version}${BOOT_Type} [${Checked_Type}]" > /tmp/cloud_version
else
	echo "未知" > /tmp/cloud_version
fi
exit
