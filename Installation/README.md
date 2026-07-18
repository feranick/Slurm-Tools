1. Install packages:

sudo apt install slurm-wlm-basic-plugins slurm-wlm-basic-plugins-dev slurm-wlm-doc slurm-wlm-torque slurm-wlm slurm-client

2. Configure slurm config file, following the attached file:

sudo nano /etc/slurm-llnl/slurm.conf

3. (Re)start slurm using the file restartslurm (attached)

4. Test: run using the attached submit.sh file:

sbatch submit.sh
squeue

P.S. In case of hangs, run the following:

sudo rm -r /var/lib/slurm-llnl/slurm*
sudo restartslurm 
