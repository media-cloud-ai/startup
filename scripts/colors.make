export TERM=xterm

### COLORS - START ###
RED_COLOR=1
GREEN_COLOR=2
YELLOW_COLOR=3
BLUE_COLOR=4
PURPLE_COLOR=5
CYAN_COLOR=6
WHITE_COLOR=7
PINK_COLOR=8

OK_COLOR=$(GREEN_COLOR)
WARN_COLOR=$(YELLOW_COLOR)
ERROR_COLOR=$(RED_COLOR)
### COLORS - END ###

define cecho
    @tput setaf $(1)
    @echo $2
    @tput sgr0
endef

define displayheader
	@$(call cecho,$(1),"**********************************************************************")
	@$(call cecho,$(1),"***")
	@$(call cecho,$(1),"*** $(2)")
	@$(call cecho,$(1),"***")
	@$(call cecho,$(1),"**********************************************************************")
endef