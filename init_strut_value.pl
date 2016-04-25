use strict;
use warnings;



my $in_ori_fileile=$ARGV[0];#input file
open(my $in_ori_file,$in_ori_fileile)or die "Could not open file'$in_ori_fileile'$!";
my $targetfile=$ARGV[1];#output file
open(my $output_file,'>',$targetfile)or die "Could not open file'$targetfile'$!";


while(my $row=<$in_ori_file>)
{
   	if($row=~/^(\w+_Struct)\s+(\w+)\;(.*)$/xig)
	{
		my $struct = $1;
		my $object = $2;
		my $comments = $3;
		
	
		#my %member_hash;
		my @member_type_array=();
		my $lookupfile=$ARGV[2];#reference file
		open(my $iEnum_file,$lookupfile)or die "Could not open file'$lookupfile'$!";
		$/ = "";
		while(my $row3=<$iEnum_file>)
		{
			my $class_member = qr/\s*(\w+)\s+(\w+);.*\n/;
			my $search_class = qr/$struct/;
			#print $output_file $row3;
			chomp($row3);
			if($row3=~/struct\s+$search_class\{([^}]*)\}\;/g){
				#print $output_file $1,"\n";
				my $class_member_all = $1;
				$/ = "\n";
				
				while($class_member_all=~/$class_member/g)
				{					
						#$member_hash{"$2"} = $1;#member => member type
						push(@member_type_array,$1);
						#print  "\/\/$2 => $1\n" ; 						
				}
			}
		}		
		close $iEnum_file;

		
		my $new_row_format="$struct\t$object=\{";
		foreach (@member_type_array)
		{
			my $add_init_value;
			if(/\bint\b/i){
				$add_init_value= "0";
			}
			elsif(/ARRAY_I/i)
			{
				 $add_init_value="init_all_sites_zero_int";
			}
			elsif(/ARRAY_D/i)
			{
				$add_init_value="init_all_sites_zero_double";
			}
			else
			{
				$add_init_value="$_\(0\)";
			}

		  	$new_row_format = "$new_row_format$add_init_value\," ;
		}
		$new_row_format="$new_row_format\}\;\t$comments\n";
		$new_row_format=~s/\,\}\;/\}\;/g;
		print $output_file $new_row_format;
			
	}
	else
	{
		print $output_file $row;
	}
}
close $output_file;
close $in_ori_file;


