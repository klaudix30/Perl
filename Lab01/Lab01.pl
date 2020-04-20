#!/usr/bin/perl

#Klaudia Gołębiewska grupa 31A
#Lab01
#gk14366@zut.edu.pl

use Cwd;

sub checkParameters {
  foreach $argument(0..$#ARGV) {
      if ($ARGV[$argument] ne "-l"
        and $ARGV[$argument] ne "-L") {
        if (-d $ARGV[$argument]) {
          $cat = $ARGV[$argument];
        } else {
          $cat = "error";
        }

      }
      if ($ARGV[$argument] eq "-l") {
        $parLong = $ARGV[$argument];

      }

      if ($ARGV[$argument] eq "-L") {
        $parOwner = $ARGV[$argument];

      }
  }
}

sub searchFiles{

 foreach $file(@_) {
        if ($file eq "." || $file eq "..") {
          next;
        }

        if(defined $parOwner){
                   $uid = (stat "$cat/$file")[4];
                   $user = (getpwuid $uid)[0];
                print("$user ");
         }


        if (defined $parLong) {
                getLong($file);
        } else {
                print("$file\n");
        }

      }

}
sub checkCatalog{

if ($cat eq "error") {
		print("bledny katalog \n");
		exit;
    } else {
     if (not defined $cat) {
        $cat = getcwd();
     }
}

}

sub operationOnCatalog {

  if ($#ARGV + 1 < 4) {
      checkCatalog();
      opendir(DIR, $cat) || die "Error in opening dir $cat\n";
      my @files = sort { "\L$a" cmp "\L$b" }  readdir(DIR);
      searchFiles(@files);
      closedir(DIR);

  } else {
    print "max 3 parametry";

  }
}


sub getLong {
  ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime((stat "$cat/$_[0]")[9]);  #dzieki stat wyswietlane sa informacje o statusie pliku, bez localtime wychodza same sekundy

  $right = sprintf("%4o", (stat "$cat/$_[0]")[2] & 07777);  #pod drugim indexem jest wartosc $mode// maskujemy typ pliku dzieki %o aby uzyskac tylko uprawnienia
  @words = split //, $right;
  $changedRights = changeRights($_[0], @words);
  $date = sprintf("%d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon+1, $mday, $hour, $min, $sec);
  $allLong = sprintf("%-30.30s %-10.10s %-20.30s %-11.11s \n", $_[0], (stat "$cat/$_[0]")[7], $date, $changedRights);
  printf($allLong);

}

sub changeRights {
  my $s;
  if (-d "$cat/$_[0]") {
    $s.= 'd';
  } else {
    $s.= '-';
  }

  foreach $w(@_) {
    if ($w eq "0") {
      $s.= '---';
    }
    if ($w eq "1") {
      $s.= '--x';
    }
    if ($w eq "2") {
      $s.= '-w-';
    }
    if ($w eq "3") {
      $s.= '-wx';
    }
    if ($w eq "4") {
      $s.= 'r--';
    }
    if ($w eq "5") {
      $s.= 'r-x';
    }
    if ($w eq "6") {
      $s.= 'rw-';
    }
    if ($w eq "7") {
      $s.= 'rwx';
    }
  }

  return $s;

}

checkParameters();
operationOnCatalog();
