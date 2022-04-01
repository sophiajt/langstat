# langstat

Programming language stat gatherer. Requires Nushell 0.60

Edit the script file and set your GITHUB_USERNAME and GITHUB_PASSWORD (you can use the API key here)

Once edited, run the script:

For the last 7 days of stats:
```sh
> nu langstat.nu --week
```

For the last 30 days of stats:
```sh
> nu langstat.nu --month
```

Current version counts the number of GitHub PRs in this time span for each language.
