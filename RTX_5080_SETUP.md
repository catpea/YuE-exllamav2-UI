# RTX 5080 16GB Optimized Configuration

This guide provides optimized settings for running YuE-exllamav2-UI on an NVIDIA GeForce RTX 5080 with 16GB VRAM.

## Quick Start

The default configuration is now optimized for 16GB VRAM. Simply run:

```bash
docker-compose up -d
```

## Recommended Models for 16GB VRAM

The configuration downloads these models by default:

1. **YuE-s1-7B-anneal-en-cot-exl2-4.0bpw** (Main English model, ~4GB)
   - Best balance of quality and memory usage
   - Optimized for chain-of-thought reasoning
   - EXL2 quantized at 4.0 bits per weight

2. **YuE-s2-1B-general-exl2-6.0bpw** (Fast general model, ~1GB)
   - Lightweight and fast
   - Good for quick tasks
   - Higher precision due to smaller model size

3. **YuE-upsampler** (Required for audio quality enhancement)
   - Necessary for final output quality
   - BF16 precision

## Model Selection Options

### For Maximum Quality (uses ~10GB VRAM)
```yaml
DOWNLOAD_MODELS=YuE-s1-7B-anneal-en-cot-exl2-5.0bpw,YuE-s2-1B-general-exl2-8.0bpw,YuE-upsampler
```

### For Maximum Speed (uses ~3GB VRAM)
```yaml
DOWNLOAD_MODELS=YuE-s1-7B-anneal-en-cot-exl2-3.0bpw,YuE-s2-1B-general-exl2-4.0bpw,YuE-upsampler
```

### For Multilingual (Chinese)
```yaml
DOWNLOAD_MODELS=YuE-s1-7B-anneal-zh-cot,YuE-s2-1B-general-exl2-6.0bpw,YuE-upsampler
```

### For Multilingual (Japanese/Korean)
```yaml
DOWNLOAD_MODELS=YuE-s1-7B-anneal-jp-kr-cot,YuE-s2-1B-general-exl2-6.0bpw,YuE-upsampler
```

### Download All EXL2 Quantized Models
```yaml
DOWNLOAD_MODELS=all_exl2
```

### Skip Model Downloads (manual setup)
```yaml
DOWNLOAD_MODELS=false
```

## Hardware Specifications

Tested on:
- GPU: NVIDIA GeForce RTX 5080 16GB VRAM
- CPU: AMD Ryzen 9 7900X 12-Core Processor
- CUDA: 12.4.1

## Available EXL2 Models

All models use ExLlamaV2 quantization for efficient VRAM usage:

### 7B Models (English CoT)
- `YuE-s1-7B-anneal-en-cot-exl2-3.0bpw` - Smallest, fastest (~3.5GB)
- `YuE-s1-7B-anneal-en-cot-exl2-4.0bpw` - Recommended balance (~4.5GB)
- `YuE-s1-7B-anneal-en-cot-exl2-5.0bpw` - Higher quality (~5.5GB)
- `YuE-s1-7B-anneal-en-cot-exl2-6.0bpw` - Very high quality (~7GB)
- `YuE-s1-7B-anneal-en-cot-exl2-8.0bpw` - Maximum quality (~9GB)

### 1B Models (General)
- `YuE-s2-1B-general-exl2-3.0bpw` - Smallest (~500MB)
- `YuE-s2-1B-general-exl2-4.0bpw` - Good balance (~650MB)
- `YuE-s2-1B-general-exl2-5.0bpw` - Better quality (~800MB)
- `YuE-s2-1B-general-exl2-6.0bpw` - Recommended (~950MB)
- `YuE-s2-1B-general-exl2-8.0bpw` - Maximum quality (~1.2GB)

## Configuration Changes Made

1. **Removed Hugging Face Login Requirement**
   - No longer prompts for HF_TOKEN
   - All recommended models are publicly accessible
   - Uncomment login section in `docker/initialize.sh` if you need private models

2. **Optimized Default Models**
   - Changed from downloading all models to a curated subset
   - Prioritizes EXL2 quantized models for memory efficiency
   - Reduces initial download time from hours to ~30 minutes

3. **Memory-Efficient Setup**
   - EXL2 quantization reduces VRAM usage by 60-75%
   - Allows running larger models on consumer GPUs
   - Maintains high quality output

## Modifying Your Configuration

Edit `docker-compose.yml` and change the `DOWNLOAD_MODELS` environment variable:

```yaml
services:
  yue-exllamav2-interface:
    environment:
      - DOWNLOAD_MODELS=YuE-s1-7B-anneal-en-cot-exl2-4.0bpw,YuE-upsampler
```

Then restart the container:

```bash
docker-compose down
docker-compose up -d
```

## Performance Tips

1. **First Run**: Model download takes 20-40 minutes depending on internet speed
2. **Subsequent Runs**: Models are cached, startup takes ~2 minutes
3. **VRAM Usage**: Monitor with `nvidia-smi` to ensure you're not exceeding limits
4. **Quality vs Speed**: 4.0bpw offers the best balance for most use cases

## Troubleshooting

### Out of Memory Errors
- Switch to 3.0bpw models
- Use only one 7B model at a time
- Ensure no other GPU processes are running

### Slow Performance
- Check if you're using EXL2 models (not BF16)
- Verify GPU is being utilized with `nvidia-smi`
- Consider using the 1B model for faster inference

### Model Download Failures
- Check internet connection
- Verify Hugging Face is accessible
- Models are downloaded to `/workspace/models` in container

## Advanced: Building Custom Model Combinations

You can specify any combination of models:

```yaml
DOWNLOAD_MODELS=YuE-s1-7B-anneal-en-cot-exl2-5.0bpw,YuE-s1-7B-anneal-zh-cot,YuE-s2-1B-general-exl2-8.0bpw,YuE-upsampler
```

This gives you multiple models for different use cases without downloading everything.
