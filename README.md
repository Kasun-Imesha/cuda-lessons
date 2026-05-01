# CUDA Lessons & Tutorials 🚀

[![CUDA](https://img.shields.io/badge/CUDA-12.0-76B900?style=flat-square&logo=nvidia)](https://developer.nvidia.com/cuda-toolkit)
[![C++](https://img.shields.io/badge/C%2B%2B-17-00599C?style=flat-square&logo=c%2B%2B)](https://en.cppreference.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

A comprehensive learning resource for CUDA programming, from fundamentals to advanced GPU computing techniques.

---

## 📚 Contents

### 03-C-and-Cpp
Foundational C/C++ concepts needed for CUDA development:
- **01-pointers** - Pointer basics and memory management
- **02-custom-types** - Structs and type definitions
- **03-type-casting** - Type conversion and casting
- **04-macros-and-global-vars** - Preprocessor and global variables
- **05-compilers** - Compilation and build tools
- **06-makefiles** - Build automation with Make
- **07-debuggers** - Debugging techniques

### 05-writing-the-first-kernels
Core CUDA kernel programming:
- **01_1-vector-addition** - Simple vector addition on GPU
- **01_2-matmul** - Matrix multiplication (naive & tiled approaches)
- **01-cuda-basics** - Indexing and memory model fundamentals
- **02_kernels** - Kernel execution patterns

---

## 🎯 Getting Started

### Prerequisites
- NVIDIA GPU with CUDA Compute Capability 6.0+
- CUDA Toolkit 12.0 or higher
- C++ compiler (g++, clang, or MSVC)
- Make or CMake

### Compilation

**Compile individual files:**
```bash
nvcc -o output_name source_file.cu
```

**Using Makefiles:**
```bash
cd 05-writing-the-first-kernels/06-makefiles
make
```

---

## 📖 Resources

- **Course Tutorial**: [FreeCodeCamp CUDA Tutorial](https://www.youtube.com/watch?v=86FAWCzIe_4&t=8918s)
- **Original Repository**: [cuda-course](https://github.com/Infatoshi/cuda-course/)
- **NVIDIA Documentation**: [CUDA Toolkit Documentation](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)

---

## 💡 Key Topics Covered

- GPU memory hierarchy (global, shared, local)
- Thread blocks and grid organization
- Kernel launches and execution models
- Vector and matrix operations on GPU
- Performance optimization techniques
- Debugging GPU code

---

## 📝 Notes

Each lesson includes:
- `.cu` files (CUDA source code)
- Compiled executables
- README.md files with explanations
- Example usage and expected outputs

---

## 🤝 Contributing

Feel free to extend this repository with additional examples, optimizations, or clarifications.

---

## 📄 License

This project is part of a learning initiative based on educational resources.