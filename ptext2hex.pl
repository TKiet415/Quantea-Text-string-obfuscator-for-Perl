#!/usr/bin/perl


####################### CHANGES #######################
#  2/??/11 - New Algorthm
#  2/??/11 - Added Commands  		     #
#  2/23/11 - took out encoding for commands	     #
#  2/24/11 - Add encoding for Commands               #
#######################################################


header();

if (@ARGV == 0)
{
	usage();
	exit;
}

# perl print text obfuscator

# Open input file in read mode
open INPUTFILE, "<", $ARGV[0] or die "Invalid file\n";
# Open output file in write mode

$outfile = "";

if (@ARGV == 1)
{
	$outfile = $ARGV[0] . ".o";
} else {
	$outfile = $ARGV[1];
}


print "Output file ---> $outfile\n\n";

open OUTPUTFILE, ">", $outfile or die "Cannot open to write!\n";

print "Converting.....\n\n";


# array checking if a variable name has ended
my @varends = ("]", " ","\$_","<","\"");

# if it is javascript text, ignore the encoding and therefore, don't obfuscate it.
my @ignore_list = ("<script ", "<SCRIPT ");
my @ignore_list_end = ("</script>","</SCRIPT>");

# local initialized variables
my $isignored=0;
my $ignoreindex=0;
my $det = "";

my $linecount;

# input file.
while (<INPUTFILE>) {
	$sample = $_; 
	$k = 0;

	$linecount++;

        # checking if there is a matched string in the code.
	# if there is a "Content-type: text/html" in a print string, don't do anything.
	if ($_ =~ /Content-type: text\/html/)
	{
		
	}

	# if the line of code has "####", delete the entire line.
	elsif ($_ =~ /####/)
	{
		$_ = "";
	}

	# if the line is a print string with a javascript type, ignore it using a flag
	elsif ($_ =~ /<script/i)
	{
		$ignored = 1;
	}

	# if the flag is activated, check until there is an ending javascript
	# and reset the flag to 0.
	elsif ($ignored == 1)
	{
		if ($_ =~ /<\/script>/i)
		{
			$ignored = 0;
		}
	}

	# if we have variable names, print statements, operations, etc.
	elsif ((
	$sample =~ /\$\w+\=\"/ 
	or 
	$sample =~ /\$\w+\s\=\"/ 
	or 
	$sample =~ /\$\w+\=\s\"/ 
	or
 	$sample =~ /\$\w+\s\=\s\"/  
	)
	or
	(
   	$sample =~ /print/
	)
	or
	(
	$sample =~ /eq\s\"/
	)
	or
	(
	$sample =~ /die\s\"/
	)
	or
	(
	$sample =~ /param\(\"/
	)
	or
	(
	$sample =~ /param\(\'/
	)	or
	(
	$sample =~ /`/
	)
	)
	{
		if ($sample =~ /\`/)
		{
			$det = "`";		
		} else {
			
			$det = "\"";
		}
		####Find the first quote
		$firstquote = index($sample,$det);

       	 	####Finds the end double quote
        	$endpos = 0;
		$forslash = 0;
		
		####Find how many double Quotations in the line (\") inside a " does not count.
		#### cpos = 0;
		#### string=""
		#### flag = 0 -- unset

		#### Get letter
		#### check for double quote
		#### if double quote is found and flag is not set then 
		#### 	record it's position
		#### 	set flag
		####    get from cpos to double quote position
		####    add it to the array
		####    set cpos to current postion + 1
		#### elsif flag is set then 
		####	check if it's a double quote
		#### 	if it's a double quote then 
		####		unset flag
		#### 	else 
		####    	convert the letter to hex 
		####		add string to the array
		####    add one to cpos
	
		
		####if ($scooby eq "doo" and $type eq "dog") { print "heres a scooby snack"; }

		####qutoes in the line
		$quotesinline=0;
		####Find out how many real quotes are in the line.
		for ($j = 0; $j < length($sample);$j++)
		{
			if (substr($sample,$j,2) eq "\\$det")
			{
				$j++;
			} elsif (substr($sample,$j,1) eq $det)
			{
			
				$quotesinline++; 
			}
		}

		if  ($quotesinline % 2 == 1) 
		{
			print("There's an odd numbers of double quotes in line $linecount. Please check your code\n");

		}
		
		$totalquotes = $quotesinline/2; 
		$curs = 0;
		$firstquote = 0;
		
		$qflag = 0;

		$cstring = $sample;
		$middle = "";

		@encodedline = "";
		$cpos=0;
		$fpos=0;
		$firstpos=-1;
		$endpos=-1;
		$doublequoted = "";
		for ($n=0;$n < length($cstring);$n++)
		{
			####Get letter
			$letter = substr($cstring,$n,1);
			####check for fake quote
			if (substr($cstring,$n,1) eq $det and $qflag == 0)
			{
				$qflag = 1;
				$beginning= substr($cstring,$cpos,  $n - $cpos); 		
				$fpos = $n+1;
				$beginning .= $det;
				push(@encodedline, $beginning);
			} elsif ($qflag == 1)
			{
				if (substr($cstring,$n,2) eq "\\$det")
				{
					$n++;
				} elsif (substr($cstring,$n,1) eq $det)
				{
					$cpos = $n+1;
					$qflag = 0;
					$doublequoted = substr($cstring,$fpos, ($cpos-$fpos) - 1);
					$string = $doublequoted;
					### Take out the double and single quotes
					$string =~ s/\\\"/\"/g;
					$string =~ s/\\\'/\'/g;
	     				$myflag = 0;
	     				$newstring = "";
	     				####Go though letter by letter 
	     				for ($j=0;$j < length($string);$j++)
	     				{
	     					if (substr($string,$j,1) eq  "\$")
						{
							$myflag = 1;
						}
						if ($myflag == 1)
	        				{
							####attach it to newstring normally
							$newstring .= substr($string,$j,1);
		
							####Go though the possible strings that indicates a varible ends
							
							for $varender (@varends)
							{
								####Check for underline array
								if (substr($string,$j,1) eq "_" and substr($string,$j+1,1) eq "[")
								{
					
								} elsif ($varender eq substr($string,$j,1))
								{
									####disable flag if there is
									$myflag = 0;
									if (substr($string,$j,1) eq $det)
									{
										$newstring = substr($newstring,0,length($newstring)-1);
										$newstring .= sprintf("\\x%X", ord(substr($string,$j,1)));
									}

								}	 
							}
						} elsif ($myflag == 0)
						{
							#ignore tabs and newline and prints them out normally
							if (substr($string,$j,2) eq '\n' or substr($string,$j,2) eq '\t')
							{
						
								$newstring .= substr($string,$j,1);
								$j++;
								$newstring .= substr($string,$j,1);
							} else {
								#prints it in hex format.
								$newstring .= sprintf("\\x%X", ord(substr($string,$j,1)));
							}
						}

	     				}	

					$newstring .=  $det;
					push(@encodedline, $newstring);
				} else {
				}
					
			}	
				
		}
			
		push(@encodedline,substr($cstring, $cpos,length($cstring) - $cpos));
		
		$emb = "";
		for ($o=0;$o < @encodedline;$o++)
		{
			$emb  .= $encodedline[$o];			
		}
		$_ = $emb;
		@encodedline=();
		undef(@encodedline);
	}
	print OUTPUTFILE $_; 
} 
close INPUTFILE;
close OUTPUTFILE;

print "done!\n\n";


sub usage {
	print "ptext2hex.pl <file to convert> <output file>\n\n";
}

sub header {
	print "\n\n==[Q]=========== Perl Text to Hex v2.0 =============[Q]==\n\n";
print "         _________ \n";
print "       / _______  \\ \n";
print "       | |      \\ |           \"Where data Thrives\"\n";
print "       | |      | |\n";
print "       | |      | |  \n";
print "       | |      / \\  \n";
print "       | |      \\  \\  \n";
print "       | |_______\\  \\  u a n t e a\n";
print "        \\_________\\  \\ \n ";
print "                   \\__\\ \n";
print " =============================================================\n\n";
}
