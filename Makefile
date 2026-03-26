.PHONY: list-skills

list-skills: ## List all included skills
	@for skill in skills/*/; do \
		name=$$(basename "$$skill"); \
		desc=$$(grep -m1 '^description:' "$$skill/SKILL.md" 2>/dev/null | sed 's/^description: *"*//;s/"*$$//'); \
		printf "  %-25s %s\n" "$$name" "$$desc"; \
	done
