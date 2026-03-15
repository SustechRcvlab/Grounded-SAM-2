# Grounded SAM 2：在视频中定位并追踪任意目标

**[IDEA-Research](https://github.com/idea-research)**

[Tianhe Ren](https://rentainhe.github.io/), [Shuo Shen](https://github.com/ShuoShenDe)

[[`SAM 2 论文`](https://arxiv.org/abs/2408.00714)] [[`Grounding DINO 论文`](https://arxiv.org/abs/2303.05499)] [[`Grounding DINO 1.5 论文`](https://arxiv.org/abs/2405.10300)] [[`DINO-X 论文`](https://arxiv.org/abs/2411.14347)] [[`English README`](./README.md)]

[![视频演示](./assets/grounded_sam_2_intro.jpg)](https://github.com/user-attachments/assets/f0fb0022-779a-49fb-8f46-3a18a8b4e893)

---

## 项目简介

Grounded SAM 2 是一个面向视频的基础模型流水线，结合了 [Grounding DINO](https://arxiv.org/abs/2303.05499)、[Grounding DINO 1.5](https://arxiv.org/abs/2405.10300)、[Florence-2](https://arxiv.org/abs/2311.06242)、[DINO-X](https://arxiv.org/abs/2411.14347) 和 [SAM 2](https://arxiv.org/abs/2408.00714)，可以在视频中定位和追踪任意目标。

本仓库提供以下功能演示：
- **定位并分割任意目标**（结合 Grounding DINO / Grounding DINO 1.5 & 1.6 / DINO-X 和 SAM 2）
- **定位并追踪任意目标**（结合 Grounding DINO / Grounding DINO 1.5 & 1.6 / DINO-X 和 SAM 2）
- **检测、分割和追踪可视化**（基于强大的 [supervision](https://github.com/roboflow/supervision) 库）

---

## 最新更新

- **2025.04.20**：更新至 `dds-cloudapi-sdk` API V2 版本。`Grounding DINO 1.5` 和 `DINO-X` 所使用的 V1 版本 API 已弃用，请运行 `pip install dds-cloudapi-sdk -U` 升级。
- **2024.12.02**：支持 **DINO-X + SAM 2** 演示（目标分割与追踪）。
- **2024.10.10**：支持 `SAM 2.1` 模型。
- **2024.08.20**：支持 **Florence-2 + SAM 2** 图像演示。

---

## 目录

- [环境安装](#环境安装)
  - [不使用 Docker 安装](#不使用-docker-安装)
  - [使用 Docker 安装](#使用-docker-安装)
    - [快速启动（独立容器）](#快速启动独立容器)
    - [集成到外部 Docker Compose](#集成到外部-docker-compose)
- [演示示例](#演示示例)
  - [图像分割演示（Grounding DINO）](#图像分割演示grounding-dino)
  - [图像分割演示（Grounding DINO 1.5 & 1.6）](#图像分割演示grounding-dino-15--16)
  - [图像分割演示（DINO-X）](#图像分割演示dino-x)
  - [视频目标追踪演示](#视频目标追踪演示)
  - [自定义视频追踪演示](#自定义视频追踪演示)
  - [Florence-2 演示](#florence-2-演示)
- [常见问题](#常见问题)
- [引用](#引用)

---

## 环境安装

### 下载预训练权重

下载 SAM 2 权重：

```bash
cd checkpoints
bash download_ckpts.sh
```

下载 Grounding DINO 权重：

```bash
cd gdino_checkpoints
bash download_ckpts.sh
```

---

### 不使用 Docker 安装

首先安装 PyTorch 环境（推荐 `python=3.10`，`torch >= 2.3.1`，`torchvision>=0.18.1`，`cuda-12.1`）：

```bash
pip3 install torch torchvision torchaudio
```

设置 CUDA 环境变量（如需本地编译 Grounding DINO 的 Deformable Attention 算子）：

```bash
export CUDA_HOME=/path/to/cuda-12.1/
```

安装 Segment Anything 2：

```bash
pip install -e .
```

安装 Grounding DINO：

```bash
pip install --no-build-isolation -e grounding_dino
```

安装其他依赖：

```bash
pip install opencv-python transformers supervision pycocotools addict yapf timm
```

> [!NOTE]
> 如遇到 HuggingFace 网络问题，可设置镜像源：
> ```bash
> export HF_ENDPOINT=https://hf-mirror.com
> ```

---

### 使用 Docker 安装

本项目提供了两种 Docker 使用方式：

1. **传统方式**（`make build-image` + `make run`）：进入容器内交互使用
2. **Compose 方式**（`docker-compose.grounded_sam2.yaml`）：作为独立服务运行，支持与外部 Docker Compose 集成

#### 快速启动（独立容器）

```bash
# 构建镜像（自动检测 CUDA 版本）
make build-image

# 进入容器（GPU 直通模式）
make run
```

进入容器后，工作目录为 `/home/appuser/Grounded-SAM-2`，可直接运行演示脚本：

```bash
python grounded_sam2_tracking_demo.py
```

#### 使用 Docker Compose 启动（推荐）

```bash
# 构建并以后台模式启动服务
make run-detached

# 或者使用 docker compose 命令
docker compose -f docker-compose.grounded_sam2.yaml up -d --build

# 停止服务
make stop
```

**环境变量配置**（通过 `.env` 文件或命令行设置）：

| 变量名 | 说明 | 默认值 |
|---|---|---|
| `USE_CUDA` | 是否启用 CUDA 编译（1=启用，0=禁用） | `0` |
| `TORCH_ARCH` | GPU 计算能力（如 `7.0;7.5;8.0;8.6`） | `7.0;7.5;8.0;8.6` |
| `HF_ENDPOINT` | HuggingFace 镜像源地址 | 空（使用官方源） |
| `API_TOKEN_FOR_GD1_5` | Grounding DINO 1.5 / DINO-X API Token | 空 |
| `DATA_DIR` | 宿主机输入数据目录 | `./data` |
| `OUTPUT_DIR` | 宿主机输出结果目录 | `./outputs` |

创建 `.env` 文件示例：

```env
USE_CUDA=1
TORCH_ARCH=7.0;7.5;8.0;8.6
HF_ENDPOINT=https://hf-mirror.com
API_TOKEN_FOR_GD1_5=your_api_token_here
DATA_DIR=./data
OUTPUT_DIR=./outputs
```

**常用 Makefile 命令：**

```bash
make build-image        # 构建 Docker 镜像
make run                # 启动交互式容器（GPU 直通）
make run-detached       # 后台启动服务（compose 方式）
make stop               # 停止并移除 compose 服务
make shell              # 打开已运行容器的 bash 终端
make download-sam2-ckpts    # 在容器内下载 SAM 2 权重
make download-gdino-ckpts   # 在容器内下载 Grounding DINO 权重
```

---

#### 集成到外部 Docker Compose

如果您有一个外部的 `docker-compose.yaml`，可以通过以下两种方式集成 Grounded SAM 2 服务：

**方式一：使用 `include`（Docker Compose v2.20+）**

```yaml
# your-project/docker-compose.yaml
include:
  - path: /path/to/Grounded-SAM-2/docker-compose.grounded_sam2.yaml

services:
  my_service:
    image: my_image
    networks:
      - grounded_sam2_network   # 加入共享网络以访问 grounded_sam2 服务
    environment:
      - GROUNDED_SAM2_HOST=grounded_sam2
    depends_on:
      - grounded_sam2
```

**方式二：使用外部网络（推荐用于跨项目集成）**

先启动 Grounded SAM 2 服务：

```bash
cd /path/to/Grounded-SAM-2
docker compose -f docker-compose.grounded_sam2.yaml up -d
```

然后在您的外部项目中，通过 `external: true` 加入已有网络：

```yaml
# your-project/docker-compose.yaml
services:
  my_service:
    image: my_image
    networks:
      - grounded_sam2_net

networks:
  grounded_sam2_net:
    name: grounded_sam2_network
    external: true
```

这样 `my_service` 容器可以通过主机名 `grounded_sam2` 访问 Grounded SAM 2 容器。

---

## 演示示例

### 图像分割演示（Grounding DINO）

**使用 HuggingFace API（简单易用）：**

```bash
python grounded_sam2_hf_model_demo.py
```

**使用本地预训练权重：**

```bash
python grounded_sam2_local_demo.py
```

**自动保存分割结果：**

在演示脚本中设置 `DUMP_JSON_RESULTS=True`，结果将以如下格式保存至 `outputs/` 目录：

```json
{
    "image_path": "path/to/image.jpg",
    "annotations": [
        {
            "class_name": "class_name",
            "bbox": [x1, y1, x2, y2],
            "segmentation": {"size": [h, w], "counts": "rle_encoded_mask"},
            "score": 0.95
        }
    ],
    "box_format": "xyxy",
    "img_width": 640,
    "img_height": 480
}
```

---

### 图像分割演示（Grounding DINO 1.5 & 1.6）

安装最新 DDS Cloud API：

```bash
pip install dds-cloudapi-sdk --upgrade
```

在 [deepdataspace.com](https://deepdataspace.com/request_api) 申请 API Token，然后运行：

```bash
python grounded_sam2_gd1.5_demo.py
```

**高分辨率图像推断（SAHI 切片推断）：**

在 `grounded_sam2_gd1.5_demo.py` 中设置 `WITH_SLICE_INFERENCE = True` 后运行，适合处理含有密集小目标的高分辨率图像（如 4K 图像）。

---

### 图像分割演示（DINO-X）

```bash
python grounded_sam2_dinox_demo.py
```

---

### 视频目标追踪演示

基于 SAM 2 强大的追踪能力，结合 Grounding DINO 实现开放集目标分割与追踪：

```bash
python grounded_sam2_tracking_demo.py
```

追踪结果保存在 `./tracking_results` 目录，演示视频保存为 `children_tracking_demo_video.mp4`。

**支持多种提示类型：**
- **点提示（Point Prompt）**：从 Grounding DINO 检测框内均匀采样点
- **框提示（Box Prompt）**：直接使用 Grounding DINO 输出的检测框
- **掩码提示（Mask Prompt）**：使用 SAM 2 图像预测器生成的掩码

---

### 自定义视频追踪演示

用户可上传自己的视频文件（如 `.mp4`），并指定文本提示进行追踪：

```bash
# 使用 HuggingFace Grounding DINO
python grounded_sam2_tracking_demo_custom_video_input_gd1.0_hf_model.py

# 使用本地 Grounding DINO 模型
python grounded_sam2_tracking_demo_custom_video_input_gd1.0_local_model.py

# 使用 Grounding DINO 1.5
python grounded_sam2_tracking_demo_custom_video_input_gd1.5.py

# 使用 DINO-X
python grounded_sam2_tracking_demo_custom_video_input_dinox.py
```

在脚本中可自定义以下参数：

```python
VIDEO_PATH = "./assets/hippopotamus.mp4"
TEXT_PROMPT = "hippopotamus."
OUTPUT_VIDEO_PATH = "./hippopotamus_tracking_demo.mp4"
API_TOKEN_FOR_GD1_5 = "your_api_token"
PROMPT_TYPE_FOR_VIDEO = "mask"
```

---

**连续 ID 追踪（全视频新目标发现）：**

```bash
python grounded_sam2_tracking_demo_with_continuous_id.py
```

参数说明：
- `text`：文本提示
- `video_dir`：视频目录
- `output_dir`：输出目录
- `step`：帧采样步长
- `box_threshold`：检测框阈值
- `text_threshold`：文本匹配阈值

---

**实时摄像头追踪：**

```bash
python grounded_sam2_tracking_camera_with_continuous_id.py
```

---

### Florence-2 演示

#### 图像分割演示

Florence-2 支持以下任务提示：

| 任务 | 提示符 | 是否需要文本输入 |
|:---:|:---:|:---:|
| 目标检测 | `<OD>` | ✗ |
| 密集区域描述 | `<DENSE_REGION_CAPTION>` | ✗ |
| 区域提案 | `<REGION_PROPOSAL>` | ✗ |
| 短语定位 | `<CAPTION_TO_PHRASE_GROUNDING>` | ✓ |
| 指代分割 | `<REFERRING_EXPRESSION_SEGMENTATION>` | ✓ |
| 开放词汇检测与分割 | `<OPEN_VOCABULARY_DETECTION>` | ✓ |

```bash
# 目标检测与分割
python grounded_sam2_florence2_image_demo.py \
    --pipeline object_detection_segmentation \
    --image_path ./notebooks/images/cars.jpg

# 密集区域描述与分割
python grounded_sam2_florence2_image_demo.py \
    --pipeline dense_region_caption_segmentation \
    --image_path ./notebooks/images/cars.jpg

# 短语定位与分割
python grounded_sam2_florence2_image_demo.py \
    --pipeline phrase_grounding_segmentation \
    --image_path ./notebooks/images/cars.jpg \
    --text_input "The image shows two vintage Chevrolet cars parked side by side."

# 指代表达式分割
python grounded_sam2_florence2_image_demo.py \
    --pipeline referring_expression_segmentation \
    --image_path ./notebooks/images/cars.jpg \
    --text_input "The left red car."

# 开放词汇检测与分割（多类别用 <and> 分隔）
python grounded_sam2_florence2_image_demo.py \
    --pipeline open_vocabulary_detection_segmentation \
    --image_path ./notebooks/images/cars.jpg \
    --text_input "car <and> building"
```

#### 图像自动标注流水线

利用 Florence-2 的描述能力级联短语定位，实现自动图像标注：

```bash
# Caption + Phrase Grounding
python grounded_sam2_florence2_autolabel_pipeline.py \
    --image_path ./notebooks/images/groceries.jpg \
    --pipeline caption_to_phrase_grounding \
    --caption_type caption

# 更细粒度的描述（--caption_type detailed_caption 或 more_detailed_caption）
python grounded_sam2_florence2_autolabel_pipeline.py \
    --image_path ./notebooks/images/groceries.jpg \
    --pipeline caption_to_phrase_grounding \
    --caption_type detailed_caption
```

---

## 常见问题

<details>
<summary>遇到 <code>ImportError: cannot import name '_C' from 'sam2'</code></summary>
<br/>
通常是因为没有执行 <code>pip install -e ".[notebooks]"</code> 或安装失败。请先安装 SAM 2，如果问题持续，尝试：
<pre><code>python setup.py build_ext --inplace</code></pre>
</details>

<details>
<summary>遇到 <code>MissingConfigException: Cannot find primary config</code></summary>
<br/>
通常是因为没有将本仓库根目录加入 Python 路径。请执行：
<pre><code>export PYTHONPATH="/path/to/Grounded-SAM-2:${PYTHONPATH}"</code></pre>
</details>

<details>
<summary>遇到 <code>CUDA_HOME environment variable is not set</code></summary>
<br/>
请设置 CUDA_HOME 环境变量：
<pre><code>export CUDA_HOME=/usr/local/cuda</code></pre>
</details>

<details>
<summary>HuggingFace 模型下载失败 / 网络超时</summary>
<br/>
设置 HuggingFace 镜像源：
<pre><code>export HF_ENDPOINT=https://hf-mirror.com</code></pre>
使用 Docker 时，在 <code>.env</code> 文件中设置 <code>HF_ENDPOINT=https://hf-mirror.com</code>。
</details>

<details>
<summary>Docker 容器中 GPU 不可用</summary>
<br/>
确保已安装 <a href="https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html">NVIDIA Container Toolkit</a>，并确认运行：
<pre><code>docker run --rm --gpus all nvidia/cuda:12.1.0-base-ubuntu22.04 nvidia-smi</code></pre>
能够正确输出 GPU 信息。
</details>

---

## 引用

如果本项目对您的研究有帮助，请引用以下文献：

```bibtex
@misc{ravi2024sam2segmentimages,
      title={SAM 2: Segment Anything in Images and Videos},
      author={Nikhila Ravi et al.},
      year={2024},
      eprint={2408.00714},
      archivePrefix={arXiv},
      primaryClass={cs.CV}
}

@article{liu2023grounding,
  title={Grounding dino: Marrying dino with grounded pre-training for open-set object detection},
  author={Liu, Shilong and others},
  journal={arXiv preprint arXiv:2303.05499},
  year={2023}
}

@misc{ren2024grounding,
      title={Grounding DINO 1.5: Advance the "Edge" of Open-Set Object Detection},
      author={Tianhe Ren and others},
      year={2024},
      eprint={2405.10300},
      archivePrefix={arXiv},
      primaryClass={cs.CV}
}

@misc{ren2024grounded,
      title={Grounded SAM: Assembling Open-World Models for Diverse Visual Tasks},
      author={Tianhe Ren and others},
      year={2024},
      eprint={2401.14159},
      archivePrefix={arXiv},
      primaryClass={cs.CV}
}
```
