#!/usr/bin/perl

#Klaudia Gołębiewska grupa 31A
#Lab02
#gk14366@zut.edu.pl
use DateTime;
use POSIX;
sub checkParameters{

if ($ARGV[$argument]=~ m/.ics/) {
        $file = $ARGV[$argument];
      }else{
		print("bledny plik \n");
		exit;
	  }

}

sub getHours{
	if (open(my $fh, $file)) {

		while (defined($row=<$fh>)) {
			chomp $row;
			getStartHours($row,'DTSTART;TZID');
			getEndHours($row,'DTEND;TZID');
			subject($row,'SUMMARY:(.*?)-');
			formS($row,'DTEND;TZID=(.*):(.*)T');
			formZ($row);
			}	
		} else {
		warn "nie mozna otworzyc  '$file'";
	}
}

sub getStartHours{
	if($_[0]=~m/$_[1]/){
		if($_[0]=~m/T(\d{2})(\d{2})/){
		$startHour=$1;
		$changedHours=$startHour*60;
		$startMin = $2;
		$changedHours+=$startMin;
		push @listStartHours, $changedHours;	
	}
	
}
}

sub getEndHours{
if($_[0] =~m/$_[1]/){
	if($_[0]=~m/T(\d{2})(\d{2})/){
		$endHour = $1;
		$changedHours=$endHour*60;
		$endMin = $2;
		$changedHours+=$endMin;
	}
		push @ListEndHours,$changedHours;
		
	}	
}

sub countHours{
	$length = @ListEndHours;

	for(my $i=0;$i<$length;$i++){
		$minLesson=$ListEndHours[$i]-$listStartHours[$i];

		$freeTime=floor($minLesson/90);

		if($freeTime==1){
			$minLesson-=5;	
		}else{
			$minLesson-=($freeTime*15);
		}
		$h=floor($minLesson/45);

		push @listHours,$h;

	}
}
sub subject{
	if($_[0]=~m/$_[1]/){
		push @listSubject,$1; 
		}
		
}
sub formZ{

	if($_[0]=~$_[1]){
		if($_[0]=~m/_W_/ || $_[0]=~m/_W,/)
		{
			push @listFormZ,"Wyklad";
			}
		if($_[0]=~"_L_" || $_[0]=~"_L"){
			push @listFormZ,"Labolatorium";
		}			
		if($_[0]=~"_P_"){
			push @listFormZ,"Projekt";	
			}	
	}

}

sub formS{
	if($_[0] =~m/$_[1]/){

		$day = substr($2, -2);
		$month= substr($2, -4, -2);
		$year= substr($2, -8, -4);
		$dt = DateTime->new(year => $year, month => $month, day => $day);
		if($dt->day_name =~ m/Saturday/ || $dt->day_name =~ m/Sunday/ ){
			push @listFormS,"niestacjonarne";
		}else{
			push @listFormS,"stacjonarne";
		}
	}	

}
sub connectList{

	$length=@listSubject;
	
	for(my $i=0;$i<$length;$i++){

		push @connectedThreeList,"$listSubject[$i],$listFormS[$i],$listFormZ[$i]";
	}	
	
}

sub mergeSameSubject{
	$length=@listSubject;
	foreach my $value (@connectedThreeList) {
		if (! $seen{$value}++ ) {
			push @unique,$value;
		}
	}
	getAllHoursForSubject(@unique);
	
}
sub getAllHoursForSubject{

	$k=0;
	foreach my $line(@_){
		$sumHours=0;
		for(my $i=0;$i<$length;$i++){
			if($line eq $connectedThreeList[$i]){
				$sumHours+=$listHours[$i];			
				$connectedList[$k]="$line,$sumHours";				
			}
		}
		$k++;
	}
}

sub getFinalAll{

	foreach my $v(@connectedList) {
		print("$v\n");  
	}
}

sub createCSV{
	open(DES,'>',"plik.csv") or die $!;
	print DES "\"Przedmiot\",\"Forma studiow\",\"Forma zajec\",\"liczba godzin\",\n";
	foreach $line(@connectedList){
		@tab=split(",",$line);
		foreach $line(@tab){
			print DES "\"".$line."\"".",";
		}
		print DES "\n";
	}

}

checkParameters();
getHours();
countHours();
connectList();
mergeSameSubject();
#getFinalAll();
createCSV();




