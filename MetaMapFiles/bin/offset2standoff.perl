#!/usr/bin/perl -w
#
# Convert Francois Lang's piped separated format to Brat's standoff format.
#
# Example of usage:
# 
#    ./offset2standoff.perl EVEROLIMUS_adverse_reactions.OFFSETs
#    creates ./EVEROLIMUS_adverse_reactions.ann
#
# Script can be called on multiple *.OFFSETs files, e.g.,
#    ./offset2standoff.perl *.OFFSETs
#
# Given:
#     53,70|FP|adverse reactions|C0559546|10067484|patf                SAME
#     181,207|TP|Non-infectious pneumonitis|C0264376|10006469|dsyn     OLD
 
#     252,262|TP|Infections|252,262|Infections|C3714514|10021789|patf  NEW

#     181,207|PTdiff|Non-infectious pneumonitis|C0264376|C0264376|10035742|10006469|dsyn
#     181,207|PTdiff|Non-infectious pneumonitis|C0264376|10035742|181,207|Non-infectious pneumonitis|C0264376|10006469|dsyn
#     2764,2769|CUIdiff|Fatal|C1306577|10011906|2764,2769|Fatal|C1705232|10060933|fndg

#     2422,2431|FN|increased                                           SAME
#     2456,2459|FN|AST                                                 SAME
#
# The following is generated:
#     T2	FP 53 70	adverse reactions
#     N4	Reference T2 SemType:patf	adverse reactions
#     N5	Reference T2 CUI:C0559546	adverse reactions
#     N6	Reference T2 MedDRA:10067484	adverse reactions
#     T3	TP 181 207	Non-infectious pneumonitis
#     N7	Reference T3 SemType:dsyn	Non-infectious pneumonitis
#     N8	Reference T3 CUI:C0264376	Non-infectious pneumonitis
#     N9	Reference T3 MedDRA:10006469	Non-infectious pneumonitis
#     T4	PTdiff 181 207	Non-infectious pneumonitis
#     N10	Reference T4 SemType:dsyn	Non-infectious pneumonitis
#     N11	Reference T4 CUI:C0264376	Non-infectious pneumonitis
#     N12	Reference T4 CUI:C0264376	Non-infectious pneumonitis
#     N13	Reference T4 MedDRA:10035742	Non-infectious pneumonitis
#     N14	Reference T4 MedDRA:10006469	Non-infectious pneumonitis
#     T5	FN 2422 2431	increased
#     T6	FN 2456 2459	AST
#

use strict;

my @AllInputFiles = ();
if ( $#ARGV >= 0 ) {
    @AllInputFiles = @ARGV;
} else {
  print "usage: offsets_filename\n";
  exit 0;
}
  
my $SemType = undef;
my ( $posinfo, $type, $term, $MMOffsets, $MMText,
     $MMCUIs, $MMMedDRAids, $CUIs, $MedDRAid, $SemTypes ) = undef;

# my $CUIlist = undef;
# my $mdrlist = undef;
# my $mdrid   = undef;
# my @mdrlist = undef;
# my @CUIlist = undef;

for my $InputFile ( @AllInputFiles ) {
    &gen_BRAT_ann($InputFile);
} # for my $file ( @AllFiles )

sub gen_BRAT_ann {
    my ( $InputFile ) = @_;

    open(IN, "<", $InputFile ) || die "Can't open $InputFile for reading!\n";
    print "Generating annotation file for $InputFile\n";
    # Accumulate in @OUTPUT all lines to be written to $OutputFile
    my @OUTPUT;
    my $ti = 1;
    my $ni = 1;
    while (<IN>) {
      chomp;
      my $Line = $_;	
      my @fields = split /\|/, $Line;

      $MMOffsets = "";
      $MMText = "";
      $MMCUIs = "";
      $MMMedDRAids = "";
      $SemTypes = "";

      if ( ($fields[1] eq "CUIDiff") || ($fields[1] eq "MedDRADiff") ) {
          ( $posinfo, $type, $term, $CUIs, $MedDRAid,
            $MMOffsets, $MMText, $MMCUIs, $MMMedDRAids, $SemTypes ) = @fields;
	  # The two undef fields are the MetaMap offsets and string
	  # This should not happen, but check anyway!
	  die "Unexpected annotation type \"$type\" in line $Line!\n"
	      if $type ne "CUIDiff" && $type ne "MedDRADiff";
	  &validate_fields_6( $Line, $posinfo, $CUIs, $MMCUIs, $MedDRAid, $MMMedDRAids, $SemTypes );

          # @CUIlist = split /,/, $CUIs;
          # @mdrlist = split /,/, $MedDRAid;

      } # if (($fields[1] eq "PTdiff") || ($fields[1] eq "CUIdiff"))
      elsif ($fields[1] eq "FN") {
	  # This should not happen, but check anyway@
          ( $posinfo, $type, $term) = @fields;
	  die "Unexpected annotation type \"$type\" in line $Line!\n"
	      if $type ne "FN";
	  &validate_posinfo( $Line, $posinfo );
          # @mdrlist = ();
          # @CUIlist = ();
          $SemTypes = "";
      } # elsif ($fields[1] eq "FN")
      elsif ($fields[1] eq "FP") {
          ( $posinfo, $type, $term, $CUIs, $MedDRAid, $SemTypes ) = @fields;
	  &validate_fields_4( $Line, $posinfo, $CUIs, $MedDRAid, $SemTypes );
          # @CUIlist = split /,/, $CUIs;
          # @mdrlist = split /,/, $MedDRAid;
      } # elsif ($fields[1] eq "FP") {
      elsif ($fields[1] eq "TP") {
          ( $posinfo, $type, $term, $CUIs, $MedDRAid, $MMOffsets, $MMText, $MMCUIs, $MMMedDRAids, $SemTypes ) = @fields;
	  # This should not happen, but check anyway!
	  die "Unexpected annotation type \"$type\" in line $Line!\n"
	      if $type ne "TP";
	  &validate_fields_4( $Line, $posinfo, $CUIs, $MedDRAid, $SemTypes );
          # @CUIlist = split /,/, $CUIs;
          # @mdrlist = split /,/, $MedDRAid;

      } # elsif ($fields[1] eq "TP")
      else {
	  $type = $fields[2];
	  die "\"$type\" is an unexpected field in line \"$Line\"!\n";
      }
      # my ($start, $end) = split /,/,$posinfo;
      $posinfo =~ s/,/ /g;
      # write text bound annotation
      push @OUTPUT,
           sprintf("T%d\t%s %s\t%s\n", $ti, $type, $posinfo, $term);
      # foreach my $CUI (@CUIlist) {
          # write reference annotations for umls concept ids referencing text bound annotation.
	  # Display all CUIs on one line
	  push @OUTPUT,
	       sprintf("N%d\tReference T%d %s:%s\t%s\n", $ni, $ti, "CUI", $CUIs, " ");
          ++$ni;
      # } # foreach $CUI (@CUIlist)
      my @SemTypelist = split /,/, $SemTypes;
      # foreach $SemType (@SemTypelist) {
	  # Write reference annotations for umls semantic types referencing text bound annotation.
      if ( $SemTypes ne "" ) {
	  # Display all SemTypes on one line
          push @OUTPUT,
               sprintf("N%d\tReference T%d %s:%s\t%s\n", $ni, $ti, "SemType", $SemTypes, " ");
          ++$ni;
      } # if ( $SemTypes ne "" )
      # } # foreach $SemType (@SemTypelist)
      # foreach $mdrid (@mdrlist) {
          # write reference annotations for MedDRA ids referencing text bound annotation.
	  # Display all MedDRA IDs on one line
          push @OUTPUT,
               sprintf("N%d\tReference T%d %s:%s\t%s\n", $ni, $ti, "MedDRA", $MedDRAid, " ");
          ++$ni;
      # } # foreach $mdrid (@mdrlist)

      if ( $MMOffsets ne "" ) {

	  push @OUTPUT,
	      sprintf("N%d\tReference T%d %s:%s\t%s\n", $ni, $ti, "MMText", $MMText, " ");
	  ++$ni;
          my @MMCUIList = split /,/, $MMCUIs;

	  # foreach my $MMCUI ( @MMCUIList ) {
	  # Display all CUIs on one line
	       push @OUTPUT,
	           sprintf("N%d\tReference T%d %s:%s\t%s\n", $ni, $ti, "MMCUI", $MMCUIs, " ");
               ++$ni;
	  # } # foreach my $MMCUI ( @MMCUIList )

          my @MMMedDRAidList = split /,/, $MMMedDRAids;
	  # foreach my $MMMedDRAid ( @MMMedDRAidList ) {
	  # Display all MedDRA IDs on one line
	       push @OUTPUT,
	           sprintf("N%d\tReference T%d %s:%s\t%s\n", $ni, $ti, "MMMedDRA", $MMMedDRAids, " ");
               ++$ni;
	  # } # foreach my $MMCUI ( @MMCUIList )
      } # if ( $MMOffsets ne "" )
	      
      ++$ti;
    } # while (<IN>)
    close IN;
    # $InputFile  is e.g., OFFSETs/EVEROLIMUS_adverse_reactions.OFFSETs
    # $OutputFile is e.g., EVEROLIMUS_adverse_reactions.ann

    # remove all chars up to and including the last "/"
    ( my $OutputFile = $InputFile ) =~ s/.*\///;
    # change "OFFSETs" suffix to "ann"
    ( $OutputFile = $InputFile ) =~ s/\.OFFSETs/.ann/;
    print "Generating annotation file $OutputFile\n";
    open(OUT, ">", $OutputFile ) || die "Can't open $OutputFile for writing!\n";
    print OUT @OUTPUT;
    close OUT;    
} # sub gen_BRAT_ann

sub validate_fields_4 {
    my ( $Line, $posinfo, $CUI, $MedDRAid, $SemTypes ) = @_;
    &validate_posinfo($Line, $posinfo);
    &validate_CUI($Line, $CUI);
    &validate_MedDRAid($Line, $MedDRAid);
    &validate_semtypes($Line, $SemTypes);
} # sub validate_fields_4


sub validate_fields_6 {
    my ( $Line, $posinfo, $CUI0, $CUI1, $MedDRAid0, $MedDRAid1, $SemTypes ) = @_;
    &validate_posinfo($Line, $posinfo);
    &validate_CUI($Line, $CUI0);
    &validate_CUI($Line, $CUI1);
    &validate_MedDRAid($Line, $MedDRAid0);
    &validate_MedDRAid($Line, $MedDRAid1);
    &validate_semtypes($Line, $SemTypes);
} # sub validate_fields_6

sub validate_posinfo {
    my ( $Line, $posinfo ) = @_;
    die "Unexpected posinfo field \"$posinfo\" in line \"$Line\"!\n"
	# DIGITS,DIGITS optionally followed by one or more ";DIGITS,DIGITS"
	if $posinfo !~ /^\d+,\d+(?:;\d*.\d*)*$/;
} # sub validate_posinfo

sub validate_CUI {
    my ( $Line, $CUI ) = @_;
    # "C0035078", or "C0035078,C1963154", or "C0035078,C1963154,C0035078", etc.
    die "Unexpected CUI field \"$CUI\" in line \"$Line\"!\n"
	if $CUI !~ /^C\d+(?:,C\d+)*$/;
} # sub validate_CUI

sub validate_MedDRAid {
    my ( $Line, $MedDRAid ) = @_;
    # "10068631" or "10068631,10068631" or "10068631,10068631,10012378", etc.
    die "Unexpected MedDRA ID field \"$MedDRAid\" in line \"$Line\"!\n"
	if $MedDRAid !~ /^\d+(?:,\d+)*$/;
} # sub validate_MedDRAid

sub validate_semtypes {
    my ( $Line, $SemTypes ) = @_;
    # "mobd" or "mobd,sosy" or "mobd,sosy,mobd" or "mobd,sosy,mobd,fndg", etc.
    die "Unexpected SemTypes field \"$SemTypes\" in line \"$Line\"!\n"
	if $SemTypes !~ /^[a-z]{4}(?:,[a-z]{4})*$/;
} # sub validate_MedDRAid
