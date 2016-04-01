#!/usr/bin/perl
my @all,@haps,@legend,@gen;
sub getRef
{
	my($ref_dir) = @_;
	if(-f  $ref_dir)
	{
		open(BUFF,$ref_dir)or die "no file ref_dir metafile $ref_dir found\n"; 
		while(<BUFF>)
		{
			$_ =~ s/\t+/ /g;
			$_ =~ s/\s+/ /g;
			@array=split(" ",$_);
			if(@array != 2)
			{
				die "the number of fields in the meta ref file has more than two columns.$_\n";
			}
			$ref_meta{lc($array[0])}=$array[1];
		}
		close(BUFF);
	}
	else
	{
		if(!(-d $ref_dir) )
		{
			die "Ref dir or mapping file $ref_dir not exists\n";
		}	
		$files=`ls $ref_dir`;
		chomp($files);
		@files=split("\n",$files);
		#print @files."\n";
		for(my $chr=23;$chr>0;$chr--)
		{
			if($chr==23)
			{
				$word="chrX";
			}
			else
			{
				$word="chr$chr";
			}
			undef(@all);
			@all = grep {/$word/i} @files; 
			if(@all < 3)
			{
				die "chromsome $word doesn't have hap,legend & genetic marker file $ref_dir.So provide the mapping file manually \n";
			}
			undef(@haps);
			#processing haps file
			$word="hap";
			@haps = grep {/$word/i} @all;
			if(@haps < 1)
			{
				die "chromsome $chr doesn't have hap  file $ref_dir.So provide the mapping file manually\n";
			}
			elsif(@haps > 1)
			{
				if($chr==23)
				{
					$word="nonPAR";
					@par_haps= grep {/$word/i} @haps;
					if(@par_haps < 1)
							{
									die "chromsome $chr doesn't have Xchr hap (nonPAR) file $ref_dir.So provide the mapping file manually\n";
							}
					if(@par_haps ==1)
					{
						$ref_meta{"chr$chr".'_'."hap"}=$par_haps[0];
					}
				}
				else
				{
					die "there are than one haps file for chromosome $chr in the $ref_dir.So provide the mapping file manually\n";
				}	
			}
			else
			{
				$ref_meta{"chr$chr".'_'."hap"}=$haps[0];
			}
			
			undef(@legend);
			#processing legend file
			$word="legend";
			@legend = grep {/$word/i} @all;
			if(@legend < 1)
			{
				die "chromsome $chr doesn't have legend  file $ref_dir.So provide the mapping file manually\n";
			}
			elsif(@legend > 1)
			{
				if($chr==23)
				{
					$word="nonPAR";
					@par_legend= grep {/$word/i} @legend;
					if(@par_legend < 1)
					{
							die "chromsome $chr doesn't have Xchr legend (nonPAR) file $ref_dir.So provide the mapping file manually\n";
					}
					if(@par_legend ==1)
					{
						$ref_meta{"chr$chr".'_'."legend"}=$par_legend[0];
					}
				}
				else
				{
					die "there are than one legend file for chromosome $chr in the $ref_dir.So provide the mapping file manually\n";
				}	
			}
			else
			{
				$ref_meta{"chr$chr".'_'."legend"}=$legend[0];
			}	
			
			undef(@genetic);
			#processing genetic marker file
			$word="genetic";
			@genetic = grep {/$word/i} @all;
			if(@genetic < 1)
			{
				die "chromsome $chr doesn't have genetic map  file $ref_dir.So provide the mapping file manually\n";
			}
			elsif(@genetic > 1)
			{
				if($chr==23)
				{
					$word="nonPAR";
					@par_genetic= grep {/$word/i} @genetic;
					if(@par_genetic < 1)
					{
							die "chromsome $chr doesn't have Xchr genetic (nonPAR) file $ref_dir.So provide the mapping file manually\n";
					}
					if(@par_genetic ==1)
					{
						$ref_meta{"chr$chr".'_'."genetic"}=$par_genetic[0];
					}
				}
				else
				{
					die "there are than one genetic map file for chromosome $chr in the $ref_dir.So provide the mapping file manually\n";
				}	
			}
			else
			{
				$ref_meta{"chr$chr".'_'."genetic"}=$genetic[0];
			}	
			
			#removing the results from main query
			$remove=join('|',@all);
			@array = grep { $_ !~ /$remove/ } @files;
			@files=@array;
			undef(@array);
			#print "$chr @files\n";
			
		}
		
		#processing sample info file
		$word="sample";
		@sample = grep {/$word/i} @files;
		if(@sample != 1)
		{
			die "number of sample files @samples is not equal to one  in the refdir $ref_dir.So provide the mapping file manually\n";
		}
		else
		{
			$ref_meta{"sample"}=$sample[0];
		}
	}		
}
return \%ref_meta;
#getDetails("kk.txt","geneEXP");
