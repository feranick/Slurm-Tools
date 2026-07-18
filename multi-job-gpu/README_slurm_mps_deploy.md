# SLURM + MPS Deployment Checklist

Steps to deploy and verify the SLURM GPU-sharing (MPS) configuration after
copying `slurm.conf`, `gres.conf`, and `cgroup.conf` into `/etc/slurm/`.

Examples below use `carbonio` (1x GTX 1080 Ti). Substitute the hostname and
expected `Gres`/`CfgTRES` values for `mochi` or `GridEdgeDM` as needed.

---

## 1. Sanity-check the files are in place and readable

```
ls -l /etc/slurm/slurm.conf /etc/slurm/gres.conf /etc/slurm/cgroup.conf
```

They should be owned by `root` (or `slurm`) and world-readable. If you copied
as root they're fine.

## 2. Confirm the GPU device node matches gres.conf

```
ls -l /dev/nvidia*
```

You should see `/dev/nvidia0`. If it's a different number, edit the `File=`
line in `/etc/slurm/gres.conf`.

## 3. Validate the config before restarting

Catches typos so the daemon doesn't fail to start.

```
sudo slurmctld -D -t
```

`-t` tests and exits without running. If it prints errors, fix them first.
(If that build doesn't accept `-t`, skip this and rely on the log check in
step 7.)

## 4. Turn on the NVIDIA persistence daemon

Keeps the GPU initialized for MPS.

```
sudo nvidia-smi -pm 1
```

## 5. Restart both daemons

```
sudo systemctl restart slurmctld slurmd
```

## 6. Check they came up

```
systemctl status slurmctld --no-pager
systemctl status slurmd --no-pager
scontrol ping
```

`scontrol ping` should say the controller is UP.

## 7. If either service failed, read the log (don't guess)

```
sudo tail -n 40 /var/log/slurm-llnl/slurmctld.log
sudo tail -n 40 /var/log/slurm-llnl/slurmd.log
```

## 8. Confirm the node picked up the new resources

```
scontrol show node carbonio | grep -E 'State|Gres|CfgTRES|RealMemory'
```

You want to see `Gres=gpu:1,mps:100` and
`CfgTRES=cpu=12,mem=38000M,...,gres/gpu=1`. If `State=DOWN` or `DRAIN`,
resume it:

```
sudo scontrol update nodename=carbonio state=resume
```

## 9. Test with a couple of real jobs

Submit the template two or three times and confirm they run concurrently on
the one GPU:

```
sbatch carbonio_sub_DAE.sh
sbatch carbonio_sub_DAE.sh
squeue
nvidia-smi          # should show multiple processes on GPU 0
```
