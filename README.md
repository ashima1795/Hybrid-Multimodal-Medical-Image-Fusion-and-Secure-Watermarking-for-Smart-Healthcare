# Hybrid-Multimodal-Medical-Image-Fusion-and-Secure-Watermarking-for-Smart-Healthcare
This project implements a hybrid multimodal medical image fusion and secure watermarking framework designed for smart healthcare applications.


The proposed system integrates:

* Visible watermarking (hospital logo embedding)
* Multimodal image fusion using DTCWT + NSST + PA-PCNN
* Dimensionality reduction using PCA
* Robust watermark embedding using NSST + SVD
* Watermark extraction and performance evaluation

The framework ensures high imperceptibility, robustness, and security for medical image transmission.

Key Features

✔ Hybrid DTCWT–NSST–PA-PCNN fusion
✔ Combined visible + invisible watermarking
✔ PCA-based host image optimization
✔ NSST-SVD embedding strategy
✔ Robust against noise, compression, and geometric attacks
✔ Performance evaluation using:

* PSNR
* SSIM
* Normalized Correlation (NC)

    Logo is resized (64×64) and embedded into the cover image
* Applied separately on RGB channels
* Transparency controlled using alpha

⸻

2️⃣ Image Fusion (DTCWT + NSST + PA-PCNN)

* Input images (CT & MRI) are:
    * Converted to grayscale
    * Decomposed using DTCWT
    * Further processed using NSST
* Fusion Strategy:
    * Low-frequency → lowpass_fuse()
    * High-frequency → highpass_fuse()
    * PA-PCNN-based selection enhances salient features

⸻

3️⃣ PCA-Based Host Image Selection

* RGB channels are reshaped and combined
* PCA applied:
    * Mean-centering
    * Covariance computation
    * Eigen decomposition
* 3rd principal component selected as host image

⸻

4️⃣ Watermark Embedding (NSST + SVD)

* Host image is:
    * Subsampled into 4 blocks
    * NSST decomposition applied
* SVD performed:
    * Cover → C = U S V^T
    * Watermark → W = U_w S_w V_w^T
* Embedding:
    S' = S + \alpha \cdot S_w
* Reconstruction:
    * Inverse SVD
    * Inverse NSST
    * Inverse PCA

⸻

5️⃣ Watermark Extraction

* Reverse process applied:
    * Subsampling
    * NSST decomposition
    * SVD extraction
* Extracted watermark:
    S_w = \frac{S' - S}{\alpha}

⸻

6️⃣ Performance Evaluation
* PSNR → imperceptibility
* SSIM → structural similarity
* NC → watermark similarity

⸻

🔹 Requirements

* MATLAB (R2018 or later recommended)
* Required toolboxes:
    * Image Processing Toolbox
    * NSST Toolbox
    * DTCWT (Shearlet toolbox)

 Important Notes

⚠ PCA uses the 3rd principal component for embedding
⚠ Subsampling assumes image size = 512×512
⚠ Missing functions required:

* lowpass_fuse()
* highpass_fuse()

⸻

🔹 Future Improvements

* Integration with deep learning-based fusion
* Real-time deployment optimization
* Enhanced encryption module
* ROI-based watermark embedding
