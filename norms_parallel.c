#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int main()
{
    int nthreads, tid;
    /* Fork a team of threads giving them their own copies of variables */
    #pragma omp parallel private(nthreads, tid)
    {
        /* Obtain thread number */
        tid = omp_get_thread_num();

        FILE *fp = popen("xspec","w");
        /* Set up some directory paths, related things */
        fprintf(fp, "set threadnum %d\n", tid);
        fprintf(fp, "set srcname _____\n");
        fprintf(fp, "set localdir /localscratch/ahollett/${srcname}\n");
	fprintf(fp, "set sharedir /share/scratch2/ahollett/${srcname}\n");
        fprintf(fp, "set filein [open /share/scratch2/agonzalez/mcp/energies/100eV/energies_T%d.dat r]\n", tid);
        fprintf(fp, "set fileout [open ${sharedir}/results/real_T%d.dat w]\n", tid);
        
        /* Set up things specific to the source / run */
        fprintf(fp, "set Emin 0.3\n");
        fprintf(fp, "set Emax 10.0\n");
        fprintf(fp, "set specfile ${localdir}/specpn_sc_SD_rbn.pha\n");
        fprintf(fp, "set model ${localdir}/_______.xcm\n");
        
        /* Set up the properties of the Gaussian line */
        fprintf(fp, "set compnum 1\n");
        fprintf(fp, "set parone 1\n");
        fprintf(fp, "set partwo 2\n");
        fprintf(fp, "set linewidth 0.01\n");
        fprintf(fp, "set parthree 3\n");
        fprintf(fp, "set stepsize 1e-6\n");
        fprintf(fp, "set stepnum 30\n");

        /* Final step, run the .xcm file containing the xspec procedure */
        fprintf(fp, "@${sharedir}/scripts/normstep.xcm\n");
        pclose(fp);
    }  /* All threads join master thread and disband */

    return 0;
}
