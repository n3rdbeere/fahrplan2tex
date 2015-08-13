# Create Herald Cards for the Chaos Communication Camp 2015

This Parser creates Cards using the Data of the Fahrplan

## Dependencies

This parser is written in Perl and needs the library 

`JSON::Parse 'json_file_to_perl'`

And the Fahrplan-data provided as json-file in this directory, named

`schedule.json`

It also uses LaTeX, only core packages are needed here.

## Usage

put the files given in this repository: https://github.com/n3rdbeere/cccamp_herald_card in the directory and then run the parser.

It will create a pdf named as the event-ID of each event in the directory.

