# Total Variation Regularisation with Spatially Variable Lipschitz Constraints

**Authors**: Yury Korolev and Simone Parisotto

**Other Authors** 
Martin Burger
Carola-Bibiane Schönlieb

**Version 1.0**

**Date: 05/12/2019**

This is a companion software for the [submission](https://arxiv.org/pdf/1912.XXXXX.pdf):

```
@article{BurKorParSch19,
 author        = {Burger, Marting and Korolev, Yury and Parisotto, Simone and Sch\"{o}nlieb, Carola-Bibiane} ,
 title         = {{Total Variation Regularisation with Spatially Variable Lipschitz Constraints}},
 year          = {2019},
 month         = {oct}, 
 journal       = {ArXiv e-prints},
 archivePrefix = {arXiv},
 eprint        = {1912.XXXXX},
}
```

#### Example
Image with Gaussian noise  (20%, std=51/255) vs. TV vs. TGV vs. TVpwL from over-TV vs. TVpwL from GT

<img src="./results/u_noise.png" width=20%> <img src="./results/u_TV_PDHG_SSIM0.64412_PSNR23.805_cputime16.99.png" width=20%> <img src="./results/u_TGV_PDHG_SSIM0.68934_PSNR24.5645_cputime111.42.png" width=20%> <img src="./results/u_TVpwL_PDHG_over_TV_SSIM0.67273_PSNR24.0509_cputime38.13.png" width=20%>  <img src="./results/u_TVpwL_PDHG_GT_SSIM0.82569_PSNR27.008_cputime17.07.png" width=20%> 


### License
[BSD 3-Clause License](https://opensource.org/licenses/BSD-3-Clause)
