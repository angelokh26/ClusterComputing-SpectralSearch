#!/bin/bash

### Edit the inputs below ###
outname=fakespec
model=bestfitcombined.xcm
spec=specpn_sc_SD_rbn.pha
#background=specpn_bg_SDscale_rbn.pha
rmf=specpn_sc_SD.rmf
arf=specpn_sc_SD.arf
#############################

for i in {1..1000}
do
echo "${i} iteration"
#xspec <<EOF
xspec > /dev/null 2>&1 <<EOF
chatter 1
@${model}
energies extend low 0.1
energies extend high 100.0
data none
fakeit none
${rmf}
${arf}
y

${outname}${i}s1.fak
93513
exit
EOF
grppha infile=${outname}${i}s1.fak outfile=${outname}${i}_grp_s1.fak comm="chkey RESPFILE ${rmf} & chkey ANCRFILE ${arf} & chkey BACKFILE none & exit"
ftgrouppha outfile=${outname}${i}_rbn_s1.fak infile=${outname}${i}_grp_s1.fak grouptype=opt respfile=${rmf}

#############################

xspec > /dev/null 2>&1 <<EOF
chatter 1
@${model}
data none
data fakespec${i}_rbn_s1.fak
energies extend low 0.1
energies extend high 100.0
fit
data none
fakeit none
${rmf}
${arf}
y

${outname}${i}.fak
93513
exit
EOF
grppha infile=${outname}${i}.fak outfile=${outname}${i}_grp.fak comm="chkey RESPFILE ${rmf} & chkey ANCRFILE ${arf} & chkey BACKFILE none & exit"
ftgrouppha outfile=${outname}${i}_rbn.fak infile=${outname}${i}_grp.fak grouptype=opt respfile=${rmf}
done
