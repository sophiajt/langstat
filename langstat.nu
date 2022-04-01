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
    let date_now = (date now)
    let date_n_days_ago = ($date_now - (1day * $num_days))

    let start = ($date_n_days_ago | date to-table)
    let end = ($date_now | date to-table)

    let start_year = $start.year.0
    let start_month = ($start.month.0 | into string | str lpad -c '0' -l 2)
    let start_day = ($start.day.0 | into string | str lpad -c '0' -l 2)

    let end_year = $end.year.0
    let end_month = ($end.month.0 | into string | str lpad -c '0' -l 2)
    let end_day = ($end.day.0 | into string | str lpad -c '0' -l 2)

    $"($start_year)-($start_month)-($start_day)..($end_year)-($end_month)-($end_day)"
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
