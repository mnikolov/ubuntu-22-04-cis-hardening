#!/usr/bin/env bash
################################################################################
# Script Name: ASLR-check-and-set.sh
# Description: Turns on ASLR and sets the appropriate kernel parameters in line with CIS benchmarks.
# Author: https://github.com/fallen-man with modifications by mnikolov (https://github.com/mnikolov/ubuntu-22-04-cis-hardening)
# Version: 0.2 2024-SEP-03
################################################################################
{
   outputfile="/etc/sysctl.d/60-kernel-cis-benchmarks.conf"

   krp="" pafile="" fafile=""
   kpname="kernel.randomize_va_space" 
   kpvalue="2"
   searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
   
   # Check if the output file is writable
   if [ ! -w "$outputfile" ]; then
      echo "ERROR: $outputfile is not writable."
      exit 1
   fi
   
   # Check if the locations in $searchloc are readable
   for loc in $searchloc; do
      if [ ! -r "$loc" ]; then
         echo "ERROR: $loc is not readable."
         exit 1
      fi
   done
   
   krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
   pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
   fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
   if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
      echo -e "\nPASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
   else
      echo -e "\nFAIL: "
      [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration\n"
      [ -n "$fafile" ] && echo -e "\n\"$kpname\" is set incorrectly in \"$fafile\""
      [ -z "$pafile" ] && echo -e "\n\"$kpname = $kpvalue\" is not set in a kernel parameter configuration file\n"

      # Set the kernel.randomize_va_space parameter to 2
      printf "\nkernel.randomize_va_space = 2\n" >> $outputfile
      sysctl -w kernel.randomize_va_space=2
      echo "The kernel.randomize_va_space parameter has been set to 2."
   fi
}
