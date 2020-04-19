#!/usr/bin/perl
#Klaudia Gołębiewska grupa 31A
#Lab03
#gk14366@zut.edu.pl
use utf8;

sub checkParameters {
    foreach $argument(0..$#ARGV) {
        if ($ARGV[$argument] =~m/.html/ ) {
            $filename = $ARGV[$argument];
        }
        if ($ARGV[$argument] =~m/.txt/ ) {
            $account = $ARGV[$argument];
        }
    }
    if (!$filename) {
        print("nie podano pliku wejsciowego \n");
        exit;
    }


}

sub readFile {

    checkParameters();
    open(my $fh, $filename)
    or die "nie mozna otworzyc pliku '$filename' ";

    while (my $row = <$fh> ) {
        chomp $row;
        if ($row=~m/<tr class='headerrow'/ ) {
            $row=~s/<tr class ='headerrow'>//;
                getHeader($row);

        }
        if ($row=~m/<tr class='problemrow'/) {

            getNames($row);
            getScores($row)
        }
    }
}
sub getHeader {

    my@ spl = split("</tr>", $_[0]);

    $allHeaders = @spl[0];
    my@ headers = split("</th>", $allHeaders);

    foreach $header(@headers) {
        $header = substr($header, 4);
        if ($header =~m/>(WIPING.*)<\/a><br>(.*)/) {
            push @listOfHeaders, $1." ".$2;

        } else {
            push @listOfHeaders, $header;
        }
    }

}

sub getNames {

    my@ rows = split("</tr>", $_[0]);
    foreach $line(@rows) {
        if ($line=~m/\/users\/(.*)'>(.*)<\/a><\/td>/) {
            push @listOfUsername, $1;
            if ($2 eq "") {
                push @listOfName, "BRAK NAZWY";
            } else {
                push @listOfName, $2;
            }
        }
    }
}

sub getScores {
    $size = @listOfHeaders;
    my@ rows = split("<td", $_[0]);
    $col = 0;
    foreach $line(@rows) {
        if ($col == $size) {

            $col = 0;
        }


        if ($line=~m/.*>(.*)<\/td><\/tr>/) {
            push @listOfScore, $1;
        }
        $line =~s/\./\,/;

        $line =~s/\-/0,0/;
        countScore($line, $col);
        $col++;
    }
}

sub countScore {
    $size = @listOfHeaders;
    if ($_[1] >= 3 && $_[1] < $size - 1) {

        if ($_[1] != 3) {
            $listOfTask[-1] = $listOfTask[-1].",\"".checkPattern($_[0])."\"";
        } else {
            push @listOfTask, "\"".checkPattern($_[0])."\"";

        }
    }

}

sub getChosenAccount {

    if ($account) {
        open(my $fh, $account)
        or die "Nie mozna otworzyc pliku";

        while (my $row = <$fh>) {
            chomp $row;
            foreach $rt(@resultTable) {

                if ($rt =~$row) {
                    push	@listOfSelected, $rt,

                }

            }
        }
    }
}

sub checkPattern {
    if ($_[0]=~m/submissions'>(.*)<\/font>/){
        $line = $1;
    }
    elsif($_[0]=~m/'>(.*)<\/td>/){
        $line = $1;
    }
    return $line;

}



sub createResultTable {
    $i = 0;
    foreach $name(@listOfName) {
        push @resultTable, "\"".$listOfUsername[$i]."\"".",\"".$name."\",".$listOfTask[$i];
        $i++;
    }
}

sub generateCsv {

    open(DES, '>', "plik.csv") or die "blad pliku";

    print DES "\"Username\",";

    $size = @listOfHeaders;

    for ($i = 1; $i < $size - 2; $i++) {
        print DES "\"".$listOfHeaders[$i]."\"".",";
    }

    print DES "\n";

    foreach $line(@_) {
        print DES $line;
        print DES ",\n";
    }

}

sub getCsv {

    if ($account) {
		if(@listOfSelected!=0){
			generateCsv(@listOfSelected);
		}else{
			print("Nie znaleziono kont \n");
			exit;
		}
    } else {
        generateCsv(@resultTable);
    }
	print("Utworzono plik.csv \n");


}


readFile();
createResultTable();
getChosenAccount();
getCsv();