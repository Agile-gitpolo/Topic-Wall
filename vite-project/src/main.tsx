/*
*******************************************************************************
 * 版权所有 (c) 2025 刘苏祺Jacob Liu
 * 保留所有权利。
 *
 * 本代码及相关内容受版权保护，未经授权禁止复制、分发、修改或用于商业目的。
 * 任何未经授权的使用，包括但不限于复制、剽窃、发布、出售，均属于侵权行为，
 * 版权人保留依法追究的权利。
 *
 * 如果您想使用或贡献本代码，请联系作者获得授权许可。
 *
 * ------------------------------------------------------------------------------
 *
 * Copyright (c) 2025 刘苏祺Jacob Liu
 * All rights reserved.
 *
 * This code and related materials are protected by copyright law.
 * Unauthorized copying, distribution, modification, or commercial use is strictly prohibited.
 * Any unauthorized use, including but not limited to copying, plagiarism, publishing, or selling,
 * constitutes infringement and the copyright holder reserves the right to pursue legal action.
 *
 * Please contact the author for permission if you wish to use or contribute to this code.
 ******************************************************************************/
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
