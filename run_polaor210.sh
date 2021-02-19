#!/bin/bash

# Source specific inputs
path=/disc31/tmp/ahollett/objects/${1}/${2}
srcname=${1}_${2}
redshift=$3
galabs=$4
prefix=$5

obsid=$2  #for readability
obj=$1

# Input information
Epomin=$(bc -l <<< "scale=4; 2.0/(1+${redshift})")
Epomax=$(bc -l <<< "scale=4; 10.0/(1+${redshift})")
EFemin=$(bc -l <<< "scale=4; 5.0/(1+${redshift})")
EFemax=$(bc -l <<< "scale=4; 7.0/(1+${redshift})")
cd ${path}/spectra/15ks
#rmf=$(ls *.rmf)
#arf=$(ls *.arf)
echo "*****"
echo "Source: ${path}"
echo "z: ${redshift}"
echo "NH/1e22: ${galabs}"
#echo "Fit range: ${Emin} - ${Emax} keV"
#echo "RMF: ${rmf}"
#echo "ARF: ${rmf}"
echo "*****"
#rm po24.xcm


spec_list=($(seq 0 15 120))   # start, step, stop .... loop ends at stop+step

#xspec > /dev/null 2>&1 <<EOF
for i in "${spec_list[@]}"
do
inext=$((i+15))
xspec <<EOF
set srcname ${srcname} 
set srcz ${redshift}
set Emin ${Epomin}
set Emax ${Epomax}
set EFemin ${EFemin}
set EFemax ${EFemax}
set exp ${i}
set rmffile ${prefix}pn_${i}-${inext}.rmf
set arffile ${prefix}pn_${i}-${inext}.arf
set NH ${galabs}
set model /disc31/tmp/ahollett/objects/${obj}/${obsid}/base_relxillfit.xcm
set fileout [open po24_params.dat w]
set srcfile ${prefix}_opt_${i}-${inext}_src.pha
set bkgfile ${prefix}_opt_${i}-${inext}_bkg.pha
@/disc31/tmp/ahollett/objects/${obj}/${obsid}/po24_fit.xcm
@po24_${i}.xcm
notice all
ign **:**-2. 10.-**
data 2 none
pl res
ipl
wdata ${srcname}_${prefix}_po24_residuals_${i}.qdp
exit
exit
EOF
done

cat ${path}/spectra/po24_params.dat
