# Gather the language PR usage data from GitHub

let GITHUB_USERNAME = "YOUR GITHUB USERNAME"
let GITHUB_PASSWORD = "YOUR GITHUB API KEY"

def main [
    --week   # gather the last 7 days of data
    --month  # gather the last 30 days of data
] {
    if $week {
        gather-data 7
    } else if $month {
        gather-data 30
    } else {
        print "Please pass either --week or --month"
    }
}

def build-range [num_days: int] {
    let date_range = (seq date --days $num_days -r)

    let start = ($date_range | get $num_days)
    let end = ($date_range | first)

    $"($start)..($end)"
}

def gather-data [num_days: int] {
    let langs = [JavaScript Java Python PHP Cpp Csharp TypeScript Shell C Ruby Go Scala Swift Rust Kotlin CSS ObjectiveC Haskell Clojure Elixir]

    let range = (build-range $num_days)

    let full_query = ($langs | reduce --fold "{\"query\": \"query { " { |it, acc|
        $acc + $" ($it): search" + '(' + $"type:ISSUE, query: \\\"language:($it) type:pr created:($range)\\\") { issueCount }"
    })

    let full_query = ($full_query + "} \"}")
    print $"Querying ($range)..."

    let output = (post https://api.github.com/graphql $full_query -u $GITHUB_USERNAME -p $GITHUB_PASSWORD)

    # Move things around a bit, since they're nested responses
    let output = ($output | get data | transpose | flatten | sort-by issueCount --reverse | transpose --header-row)

    $output | save output.csv
    print "Saved to output.csv"
}
