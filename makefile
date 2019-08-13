# Project tree.
# Source or include files can be in any folder, sub-folder, nested or not.
# The bin and obj sub-folders are created if not already exist.
#
# + project
#	+ bin
#	+ obj
#   + src          NOTE: you may use a folder named src, but it's not mandatory
#	makefile
 
# to debug this makefile use
# $(info text...) 

# application file name
# TARGET := App.exe
TARGET := $(notdir $(CURDIR).exe)

####################################################
# WARNING: remove ending spaces from the path related lines
####################################################

# paths relative to CURDIR
BIN_DIR := bin
OBJ_DIR := obj

# or src without ending slash
SRC_DIR := .

OUT_DIRS := $(OBJ_DIR)
OUT_DIRS += $(BIN_DIR)
 
# SEE: https://stackoverflow.com/questions/714100/os-detecting-makefile
#ifeq ($(shell echo "check_quotes"),"check_quotes")
ifeq ($(OS),Windows_NT)     # Windows
  WINDOWS = yes
  
  MV := move
  RM := del

# create needed folders
  $(shell mkdir $(subst /,\,$(OUT_DIRS)) >nul 2>&1 || (exit 0))

# get the current folder, we'll remove this from in-front of the collected files
  CUR_DIR := $(CURDIR)/ 
  
  # just to be sure, correct the slashes
  SRC_DIR := $(subst /,\,$(SRC_DIR))

# collect source files, reverse the slashes
  SRCS := $(shell dir $(SRC_DIR)\*.cpp $(SRC_DIR)\*.c /S /B)  
  SRCS := $(subst \,/,$(SRCS))  
  SRCS := $(subst $(CUR_DIR),,$(SRCS))

# collect header file folders, reverse the slashes  
  INC_DIRS := $(shell dir $(SRC_DIR)\*.h $(SRC_DIR)\*.hpp /S /B)   
  INC_DIRS := $(subst \,/,$(INC_DIRS))
  INC_DIRS := $(subst $(CUR_DIR),,$(INC_DIRS))
 else
  WINDOWS = no

  MV := mv -f
  RM := rm -f 

# create needed folders
  $(shell mkdir -p $(OUT_DIRS))

# just to be sure, correct the slashes
  SRC_DIR := $(subst \,/,$(SRC_DIR)) 

# collect source files
  SRCS := $(shell find $(SRC_DIR) -name *.cpp -or -name *.c -or -name *.s)

# collect header file folders
  INC_DIRS := $(shell find $(SRC_DIR) -name *.hpp -or -name *.h)
endif

# prepare inc flags
INC_DIRS := $(dir $(INC_DIRS))
INC_FLAGS = $(addprefix -I,$(INC_DIRS))

# prepare obj file paths
NO_DIRS := $(notdir $(SRCS))
OBJS := $(NO_DIRS:%=$(OBJ_DIR)/%.o)

# prepare dependency file paths
DEPS := $(OBJS:.o=.d)

# compiler flags
CPPFLAGS := $(INC_FLAGS) -MMD -MP -Wall -Wextra 

# call make as "make DEBUG=1"
ifdef DEBUG
	CPPFLAGS += -g
endif 

# VPATH built-in variable specifies a list of directories that make should search for both prerequisites and targets of rules
VPATH = $(dir $(SRCS))
 
 # link
$(BIN_DIR)/$(TARGET): $(OBJS) 
	$(CXX) $(OBJS) -o $@ $(LDFLAGS)

# compile c
$(OBJ_DIR)/%.c.o: %.c 
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# compile cpp
$(OBJ_DIR)/%.cpp.o: %.cpp 
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# clean
DELS := $(OBJS)
DELS += $(DEPS)
DELS += $(BIN_DIR)/$(TARGET)

ifeq ($(WINDOWS),yes)
	DELS := $(subst /,\,$(DELS))
endif

# clean target, calling "make clean" cleans the project
clean:
	$(shell $(RM) $(DELS))

 
   