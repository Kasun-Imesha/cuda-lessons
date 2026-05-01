.PHONY: 01 01_obj_exec_run 02 03 clean
# .PHONY tells make that certain targets are not real files, just commands to run.
# Normally, make assumes every target is a file.
# So if a file with the same name already exists, it may skip running the recipe.
# Normally make skips work if nothing changed — .PHONY turns that off

GCC = gcc
NVCC = nvcc
CUDA_FLAGS = -arch=sm_75


01:
	$(GCC) -o 01 01.c
# 	@$(GCC) -o 01 01.c  when @ is prepended, the command is not printed

# just copiles to object file
01.o: 01.c
	@echo "building obj..."
	@$(GCC) -c 01.c -o 01.o


# compiles and runs the object file (ensure 01_obj is up to date 
# by running 01_obj first if it hasn't been run yet)
# so 01_obj is the prerequisite
01_obj_exec_run: 01.o
	@$(GCC) 01.o -o 01
	@./01

02:
	@$(GCC) 02.c -o 02

03:
	@$(NVCC) $(CUDA_FLAGS) -o 03_cu 03.cu

clean:
	@rm -f 01 02 03_cu *.o
