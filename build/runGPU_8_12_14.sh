#!/usr/bin/env bash
#SBATCH --job-name=8_12_14
#SBATCH --gres=gpu:1
#SBATCH --qos=qos_gpu-t4
#SBATCH --cpus-per-task=5
#SBATCH --output=/data1/vallee/GPU_8_12_14.out
#SBATCH --error=./errors/GPU_8_12_14.err
#SBATCH --time=30:00:00
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --ntasks-per-node=1
srun time ./8_12_14
