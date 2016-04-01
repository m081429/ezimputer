$filename = $ARGV[0];
chomp($filename);
$outfile = $ARGV[1];
chomp($outfile);
$newreference_info = $ARGV[2];
chomp($newreference_info);
open BUFF,"$newreference_info" or die "no file found $newreference_info\n";
while($line = <BUFF>)
{
	chomp($line);
	@array = split(" ",$line);
	$hapmap{$array[1]} = $line;
}
open BUFF,"$filename" or die "no file exists $filename Arguments: $ARGV[0] $ARGV[1]\n";
open WRBUFF,">$outfile" or die "unable to write outfile \n";
$k1 = 0;
$samp_num = 0;
@samp_array = ();
$pop_num = 1;
while($line=<BUFF>)
{
	chomp($line);
	$line =~ s/\s+/ /g;
	$line =~ s/^\s+//g;
	$line =~ s/  / /g;
	$line =~ s/  / /g;
	#print $line."\n";
#Inferred ancestry of individuals:
#Label (%Miss) Pop:  Inferred clusters (and 90% probability intervals)
	if($line =~ m/^Inferred ancestry/ && $k1 ==0)
	{
		$k1 =1;
		#print "success\n";
		
		$liney = <BUFF>;
		$liney = <BUFF>;
		#print "$liney\n";
	}
	elsif($k1 ==1 && $line =~ m/^\d/)
	{
		#print "$line\n";
		@array = split(/ /,$line);
		
		#die $array[1]."\t".$array[3]."\t".$array[5]."\t".$array[6]."\t".$array[7]."\t".$array[8]."\t".$array[9]."\n";
		#$arr[0] = $array[5];
		#$arr[1] = $array[6];
		#$arr[2] = $array[7];
		$nu = 5;
		for($i=0;$i<$num_pop;$i++)
		{
			$arr[$i] = $array[$nu];
			$nu++;
		}
		if($array[3] == 0)
		{
			$samp_array[$samp_num] = "$array[1] $array[5] $array[6] $array[7]";
			#print "$arr[5] $arr[6] $arr[7]\n";
			#print "$samp_array[$samp_num]\n";
			$samp_num++;
		}
		else
		{
			#@index = sort { $arr[$b] <=> $arr[$a] } 0 .. $#arr;
			#print $array[1]."\t".$array[3]."\t".$index[0]."\t".$array[5]."\t".$array[6]."\t".$array[7]."\t".$array[8]."\t".$array[9]."\n";
			#$value = $index[0]+1;
			#$result = join("\t",@arr);
			$value = $array[3];
			#print "$value\t$result\n";
			#print $hapmap{$array[1]}."\n";
			#print $array[1]."\t".$array[3]."\t".$value."\t".$arr[$index[0]]."\n";
			if(exists($hapmap{$array[1]}))
			{
				#print "success\n";	
				@h_array = split(" ",$hapmap{$array[1]});
				$pop{$h_array[3]} = $pop_num;
				$pop_num++;
				if(exists(${$h_array[3]}{$value}))
				{
					${$h_array[3]}{$value}++;
				}
				else
				{
					${$h_array[3]}{$value} = 1;
				}
				#print $hapmap{$array[1]}."\n";
			}
			#else
			#{
			
				#$result{$array[1]} = $array[1]."\t".$result;
			#}
		}
	}
	else
	{
		$k1 =0;
	}
}	
while(($key,$value) = each %pop)
{
	#print $key."\n";
	$i =0;
	foreach $keyname (sort { ${$key} {$b} <=> ${$key} {$a}} keys %{$key} )
	{
	#		print $key."\t".$keyname."\t".${$key}{$keyname}."\n";
	#	if($i ==0)
	#	{
			$pop[$keyname -1] = $key; 
	#	}
	#	$i++;
	}	
}
#print "@pop\n";
$pop = join("\t",@pop);
print WRBUFF "Sample\t$pop\n";
for($i=0;$i<@samp_array;$i++)
{
	print WRBUFF $samp_array[$i]."\n";
}
#while(($key,$value) = each %result)
#{
#	print $value."\n";
#}
