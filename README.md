# Environment

Spawn a new shell and load the environment variables contained in
`~/.config/environment/<current-project-name>.<environment>`

## Usage

All the information should be available using the `-h` option.

```
$> environment -h
Usage: environment [-d|-f|-h|-v] <environment>

Flags:
  -d           Debug mode
  -f           Force loading the new enviornment even if we
               are already in one. Be careful, it might cause
               unexpected behaviour
  -h           Display this usage text
  -v           Make it more verbose

Environment Variables:
  ENVIRONMENT_CONFIG_PATH:  Path where all the environment variable files are stored.
                            Currently set to "/Users/johndoe/.config/environment"
  ENVIRONMENT_PROJECT_NAME: Base name of the file looked up in the config folder Currently
                            set to "acme_corp"

Arguments:
  environment: (Default: dev) Environment name to load. The file `acme_corp.<environment>`
               will be loaded from "/Users/johndoe/.config/environment"

Example:
  # Start a new shell with 'dev' environment variables loaded
  environment dev
```

## Tests

```
bats test
```
