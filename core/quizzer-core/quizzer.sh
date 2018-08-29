#!/bin/bash
# Quizzer - Active & Inactive Domain Checker
# @adroitadorkhan
# License: CC BY-NC-SA 4.0

# Begins
# Divider
divider="-------------------------------------"
# Start Time
start=$(date +%s)
# Version and Date -Time
version=5.0.0
date=$(date +"%Y.%m.%d - %H:%M")
time=$(date +"%T")

# Check JSON
sourceList=$(jq -c '.sources|map(select(.enabled))' "sources.json")
sourceCount=$(printf -- '%s' "$sourceList" | jq '.|length-1')

# Settings
	for i in $(seq 0 "$sourceCount"); do
		entry=$(printf -- '%s' "$sourceList" | jq ".[$i]")
		name=$(printf -- '%s' "$entry" | jq -r '.name')
		format=$(printf -- '%s' "$entry" | jq -r '.format')
		part=$(printf -- '%s' "$entry" | jq -r '.part')
		url=$(printf -- '%s' "$entry" | jq -r '.url')

# Variables
active=output/Active-$name
inactive=output/Inactive-$name
list=list.temp
maina=Active
maini=Inactive
temp=domains.temp
otemp=output/domains.temp
itemp=output/inactive.temp
stat=output/Stat-$name

# Removes previous outputs
rm -f $active
rm -f $inactive
rm -f $stat
rm -f $temp
rm -f $otemp

# Creates new outputs
touch $active
touch $inactive

# Select here to choose URL or PART
# Upper > Lower Case
tr '[:upper:]' '[:lower:]' < $part > $temp

# Cleans the domain list (Change to url, if you want from url!)
egrep -v "^[[:blank:]]*(::|localhost|#|$)" $temp > $otemp && sort $otemp|uniq|tee > $temp
sed 's/^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\} //;s/^localhost//;s/^,//;s/^-//;s/^_//;s/^;//;s/@//;s/;//;s/,//;s/+//;s/*//;s/=//;s/-$//;s/_$//;s/#.*//;s/##.*//;s/localhost$//' $temp > $list

# Read total lines
totaldomains=$(awk 'END{print NR}' $list)

# \033[1;92mActive.\033[0m
clear
echo ""
echo "\033[1;92m   _____     _ _____ _____    
  |     |_ _|_|__   |__   |___ ___
  |  |  | | | |   __|   __| -_|  _|
  |__  _|___|_|_____|_____|___|_|
     |__|\033[0m"
echo ""  
echo "         Check Active Domains"
echo "  Version: $version | © nayemador.com"
echo ""
echo "\033[1;93m$divider\033[0m"
echo '[+] Details'
echo "\033[1;93m$divider\033[0m"
echo "[+] File: \033[1;91m$name\033[0m"
echo "[+] Total Domains: \033[1;92m$totaldomains\033[0m"
echo "[+] Started: $time"
echo "\033[1;93m$divider\033[0m"
echo "\n"
echo "\033[1;92m$divider\033[0m"
echo "[+] Quizzing Begins"
echo "\033[1;92m$divider\033[0m"
while read domain
do
  # Get IP address defined in domain's root A-record
  ipaddress=`dig $domain +short`
  
  # NSLOOKUP
  # nsl=`nslookup $domain | grep -i "Name:"`

  # Get list of all nameservers
  # ns=`dig ns $domain +short| sort | tr '\n' ','`
  
  # Uncomment if you need all Whois details
  # `whois $domain >> whois-results.txt`
  
  # Use the line below to extract any information from whois
  # ns=`whois $domain | grep  "Name Server" | cut -d ":" -f 2 |  sed 's/ //' | sed -e :a -e '$!N;s/ \n/,/;ta'`
  
  echo "[+] Checking: \033[1;94m$domain\033[0m"

  # Uncomment the following lines to output the information directly into the terminal
  # echo "IP Address:  $ipaddress"
  # echo "Nameservers: $ns"
  # echo " "

# Checks if the IP isn't available then the domain is inactive.
# Else, active. Then prints the outputs.
  if [ ! "$ipaddress" ]; then
  echo "[+] Checking Whois..."
  ns=`whois $domain | grep  "Name Server"`
    if [ ! "$ns" ]; then
    echo "[+] Status: \033[1;91mInactive.\033[0m"
    echo "$domain" >> $inactive
    echo "$domain" >> $maini
    else
    echo "[+] Status: \033[1;92mActive.\033[0m"
    echo "$domain" >> $active
    echo "0.0.0.0 $domain" >> $maina
    fi
  else
  echo "[+] Status: \033[1;92mActive.\033[0m"
  echo "$domain" >> $active
  echo "$domain" >> $maina
  fi
  
  # Defines the text file from which to read domain names
done < $list

echo "\033[1;92m$divider\033[0m"
echo "[+] Done Quizzing!"
echo "\033[1;92m$divider\033[0m"
# Declaring Variables (Total Domains, Active, Inactive Numbers & Percentage)
totallines=$(awk 'END{print NR}' $list)
activelines=$(awk 'END{print NR}' $active)
deadlines=$(awk 'END{print NR}' $inactive)
percenta=$(awk "BEGIN { pc=100*${activelines}/${totallines}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
percentd=$(awk "BEGIN { pc=100*${deadlines}/${totallines}; i=int(pc); print (pc-i<0.5)?i:i+1 }")
# Echo Stats
echo "\n\033[1;93m$divider\033[0m
[+] Stats -
\033[1;93m$divider\033[0m
 Total Number: $totallines
$divider
 Status   | Percentage   | Numbers   
$divider
 Active     $percenta%           $activelines
 Inactive   $percentd%           $deadlines
$divider"
# Save Stats in Output Directory
echo "Quizzer - Active & Inactive Generated Lists Stat
Generated: $date
@adroitadorkhan
$divider
 Total Number: $totallines
$divider
 Status   | Percentage   | Numbers   
-------------------------------------
 Active     $percenta%            $activelines
 Inactive   $percentd%            $deadlines
-------------------------------------" >> $stat
# Give each column the relevant header titles
sed -i '1s/^/# Active List\n# Created with Quizzer by @adroitadorkhan\n/' $active
sed -i '1s/^/# Inactive List\n# Created with Quizzer by @adroitadorkhan\n/' $inactive
rm -f $temp
rm -f $otemp
rm -f $list
echo "[+] Lists Saved in Output Directory."
echo "[+] Done!"
done
end=$(date +%s)
diff=$(( $end - $start ))
echo "[+] Took: $diff seconds"
