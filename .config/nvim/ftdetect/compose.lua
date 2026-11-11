-- Docker Compose files get the compound filetype "yaml.docker-compose".
-- docker_compose_language_service only attaches to that filetype, and
-- Neovim's own detection stops at "yaml". The "yaml" part keeps yamlls,
-- yaml ftplugins and the yaml tree-sitter parser working as before.
vim.filetype.add({
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
  },
  pattern = {
    -- Override files such as docker-compose.override.yml or
    -- docker-compose.prod.yaml.
    [".*/docker%-compose%..+%.ya?ml"] = "yaml.docker-compose",
  },
})
