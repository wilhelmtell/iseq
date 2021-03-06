# Specify the project's name
PROJECT_NAME = "iseq"
# Specify the main target
TARGET = iseq
# Default build type
TYPE = debug
# Which directories contain source files
DIRS = .
# Which libraries are linked
LIBS =
# Dynamic libraries
DLIBS =

# The next blocks change some variables depending on the build type
ifeq ($(TYPE),debug)
LDPARAM =
CCPARAM = -Wall -g3
MACROS =
endif

ifeq ($(TYPE),profile)
LDPARAM = -pg /lib/libc.so.5
CCPARAM = -Wall -pg
MACROS = NDEBUG
endif

ifeq ($(TYPE),release)
LDPARAM = -s
CCPARAM = -O2
MACROS = NDEBUG
endif

# Add directories to the include and library paths
INCPATH = . $(HOME)/Development/include
LIBPATH = . $(HOME)/usr/lib

# Which files to add to backups, apart from the source code
EXTRA_FILES = Makefile
# The compiler
CXX = g++

# Where to store object and dependancy files.
STORE = .make-$(TYPE)
# Makes a list of the source (.cc) files.
SOURCE := $(foreach DIR,$(DIRS),$(wildcard $(DIR)/*.cc))
# List of header files.
HEADERS := $(foreach DIR,$(DIRS),$(wildcard $(DIR)/*.hh))
# Makes a list of the object files that will have to be created.
OBJECTS := $(addprefix $(STORE)/, $(SOURCE:.cc=.o))
# Same for the .d (dependancy) files.
DFILES := $(addprefix $(STORE)/,$(SOURCE:.cc=.d))

# Specify phony rules. These are rules that are not real files.
.PHONY: all clean distclean backup dirs

# Main target. The @ in front of a command prevents make from displaying
# it to the standard output.
all: $(TARGET)
$(TARGET): dirs $(OBJECTS)
	@echo " LD	$(TARGET)"
	@$(CXX) -o $(TARGET) $(OBJECTS) $(LDPARAM) $(foreach LIBRARY, \
		$(LIBS),-l$(LIBRARY)) $(foreach LIB,$(LIBPATH),-L$(LIB))

# Rule for creating object file and .d file, the sed magic is to add
# the object path at the start of the file because the files gcc
# outputs assume it will be in the same dir as the source file.
$(STORE)/%.o: %.cc
	@echo " CXX	$?"
	@$(CXX) -Wp,-MMD,$(STORE)/$*.dd $(CCPARAM) $(foreach INC,$(INCPATH),-I$(INC)) \
		$(foreach MACRO,$(MACROS),-D$(MACRO)) -c $< -o $@
	@sed -e '1s/^\(.*\)$$/$(subst /,\/,$(dir $@))\1/' $(STORE)/$*.dd > $(STORE)/$*.d
	@rm -f $(STORE)/$*.dd

# Empty rule to prevent problems when a header is deleted.
%.hh: ;

# Cleans up the objects, .d files and executables.
clean:
	@-$(foreach DIR,$(DIRS),echo " RM	$(STORE)/$(DIR)/*.d"; \
		rm -f $(STORE)/$(DIR)/*.d; \
		echo " RM	$(STORE)/$(DIR)/*.o"; \
		rm -f $(STORE)/$(DIR)/*.o)
	@-$(foreach DIR,$(patsubst .,"",$(DIRS)),if [ -d $(STORE)/$(DIR) ]; \
		then echo " RM	$(STORE)/$(DIR)"; rmdir -p $(STORE)/$(DIR); fi; )

distclean: clean
	@echo " RM	$(TARGET)"
	@-rm -f $(TARGET)

# Backup the source files.
backup:
	@-if [ ! -e .backup ]; then mkdir .backup; fi;
	@if [ -e $(PROJECT_FILENAME) ]; then echo "Directory $(PROJECT_FILENAME) already exists." >&2; false; fi;
	@mkdir $(PROJECT_FILENAME)
	@cp --archive --parents $(SOURCE) $(HEADERS) $(EXTRA_FILES) $(PROJECT_FILENAME)
	@tar c $(PROJECT_FILENAME) |gzip -9 >.backup/backup_`date +%Y%m%d%H%M`.tar.gz
	@rm -rf $(PROJECT_FILENAME)

dirs:
	@-mkdir -p $(STORE)
	@-mkdir -p $(foreach DIR,$(DIRS),$(STORE)/$(DIR))

# Includes the .d files so it knows the exact dependencies for every
# source.
-include $(DFILES)
