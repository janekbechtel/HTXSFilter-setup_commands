#!/bin/bash
export SCRAM_ARCH=slc6_amd64_gcc630
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_9_3_14/src ] ; then 
 echo release CMSSW_9_3_14 already exists
else
scram p CMSSW CMSSW_9_3_14
fi
cd CMSSW_9_3_14/src
eval `scram runtime -sh`

git cms-init
git cms-addpkg GeneratorInterface/GenFilters
git cms-addpkg GeneratorInterface/RivetInterface
git cms-addpkg  SimDataFormats
git remote add kit https://github.com/KIT-CMS/cmssw
git fetch kit
git cherry-pick 2b8fd3b3a8138fce834fab3212f0096e86505286

git clone https://github.com/janekbechtel/Configuration

scram b
cd ../../
seed="int($(date +%s)%100)"
cmsDriver.py Configuration/GenProduction/python/HIG-RunIIFall17wmLHEGS-HTXS_VBF_207-208-209-210_fragment.py --fileout file:HIG-RunIIFall17wmLHEGS-HTXS_VBF_207-208-209-210.root --mc --eventcontent RAWSIM,LHE --datatier GEN-SIM,LHE --conditions 93X_mc2017_realistic_v3 --beamspot Realistic25ns13TeVEarly2017Collision --step LHE,GEN,SIM --nThreads 8 --geometry DB:Extended --era Run2_2017 --python_filename HIG-RunIIFall17wmLHEGS-HTXS_VBF_207-208-209-210.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring --customise_commands "process.RandomNumberGeneratorService.externalLHEProducer.initialSeed=${seed}\nprocess.schedule = cms.Schedule(process.lhe_step,process.generation_step,process.filter_step,process.genfiltersummary_step,process.simulation_step,process.endjob_step,process.RAWSIMoutput_step,process.LHEoutput_step)\nprocess.genstepfilter.triggerConditions=cms.vstring(\"filter_step\")\nprocess.RAWSIMoutput.SelectEvents.SelectEvents = cms.vstring(\"filter_step\")" -n 216

