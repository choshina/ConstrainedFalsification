import sys
import platform
import glob

matlab = ''
osys = platform.system()
if osys == 'Linux':
    mpaths = glob.glob('/usr/local/MATLAB/*/bin/')
    mpaths.sort()
    matlab = mpaths[-1] + '/matlab'
elif osys == 'Darwin':
    mpaths = glob.glob('/Applications/MATLAB*/bin/')
    mpaths.sort()
    matlab = mpaths[-1] + '/matlab'

model = ''
algorithm = '' 
optimization = []
phi_str = []
controlpoints = []
input_name = []
input_range = []
parameters = []
timespan = ''
loadfile = ''

status = 0
arg = ''
linenum = 0

algopath = ''
trials = ''
timeout = ''
max_sim = ''
addpath = []

base = []
cons = []

pattern = ''

with open(sys.argv[1],'r') as conf:
	for line in conf.readlines():
		argu = line.strip().split()
		if status == 0:
			status = 1
			arg = argu[0]
			linenum = int(argu[1])
		elif status == 1:
			linenum = linenum - 1
			if arg == 'model':
				model = argu[0]

			elif arg == 'optimization':
				optimization.append(argu[0])
			elif arg == 'phi':
				complete_phi = argu[0]+';'+argu[1]
				for a in argu[2:]:
					complete_phi = complete_phi + ' '+ a
				phi_str.append(complete_phi)
			elif arg == 'controlpoints':
				controlpoints.append(int(argu[0]))
			elif arg == 'input_name':
				input_name.append(argu[0])
			elif arg == 'input_range':
				input_range.append([float(argu[0]),float(argu[1])])
			elif arg == 'parameters':
				parameters.append(argu[0])	
			elif arg == 'timespan':
				timespan = argu[0]
			elif arg == 'trials':
				trials = argu[0]
			elif arg == 'timeout':
				timeout = argu[0]
			elif arg == 'max_sim':
				max_sim  = argu[0]
			elif arg == 'addpath':
				addpath.append(argu[0])
			elif arg == 'loadfile':
				loadfile = argu[0]
			elif arg == 'cons':
				cons.append(argu[0])
			elif arg == 'pattern':
				pattern = argu[0]
				for b in argu[1:]:
					pattern = pattern + ';' + b
			else:
				continue
			if linenum == 0:
				status = 0


for ph in phi_str:
	for cp in controlpoints:
		for opt in optimization:
			for ctr in cons:
				property = ph.split(';')
				filename = model+ '_breach_' + property[0]+'_' + str(cp)  +'_' + opt + '_' + ctr + '_' + 'inf'
				param = '\n'.join(parameters)
				pat_s = pattern.split(';')
				with open('benchmarks/'+filename,'w') as bm:
					bm.write('#!/bin/sh\n')
					bm.write('csv=$1\n')
					bm.write('matlab -nodesktop -nosplash <<EOF\n')
					bm.write('clear;\n')
					for ap in addpath:
						bm.write('addpath(genpath(\'' + ap + '\'));\n')
					if loadfile!= '':
						bm.write('load ' + loadfile + '\n')
					bm.write('InitBreach;\n\n')
					bm.write(param + '\n')
					bm.write('mdl = \''+ model + '\';\n')
					bm.write('Br = BreachSimulinkSystem(mdl);\n')
					bm.write('Br.Sys.tspan ='+ timespan +';\n')
					bm.write('input_gen.type = \'UniStep\';\n') 				
					bm.write('input_gen.cp = '+ str(cp) + ';\n')
					bm.write('Br.SetInputGen(input_gen);\n')
					bm.write('for cpi = 0:input_gen.cp -1\n')
					for i in range(len(input_name)):
						bm.write('\t' + input_name[i] + '_sig = strcat(\''+input_name[i]+'_u\',num2str(cpi));\n')
						bm.write('\tBr.SetParamRanges({'+input_name[i] + '_sig},[' +str(input_range[i][0])+' '+str(input_range[i][1]) + ']);\n')
			
					bm.write('end\n')
					bm.write('spec = \''+ property[1]+'\';\n')
					bm.write('phi = STL_Formula(\'phi\',spec);\n')
					#bm.write('cons = STL_Formula(\'cons\', \'' + cons + '\');\n')

					bm.write('consfile = \'' +ctr+ '\';\n')
					bm.write('cons = parse(consfile);\n')

					bm.write('pattern = [')
					for i in range(len(pat_s)):
						for j in pat_s[i]:
							bm.write(j  + ' ')
						if i!= (len(pat_s)-1):
							bm.write(';')
					bm.write('];\n')
		
					bm.write('trials = ' + trials + ';\n')	
					bm.write('filename = \''+filename+'\';\n')
					bm.write('algorithm = \'Breach\';\n')
#					bm.write('base = ' + bs + ';\n')
					bm.write('falsified = [];\n')
					bm.write('time = [];\n')
					bm.write('obj_best = [];\n')
					bm.write('num_sim = [];\n')
		
					bm.write('for n = 1:trials\n')
				#	bm.write('\tfalsif_pb = PracticalFP_2(Br,phi, base);\n')
					bm.write('\tfalsif_pb = PFPINF2(Br,phi,cons, pattern);\n')
					if timeout!='':
						bm.write('\tfalsif_pb.max_time = '+ timeout + ';\n')
					if max_sim!='':
						bm.write('\tfalsif_pb.max_obj_eval = ' + max_sim + ';\n')
					bm.write('\tfalsif_pb.setup_solver(\''+ opt  +'\');\n')
					bm.write('\tfalsif_pb.solve();\n')
					bm.write('\tif falsif_pb.obj_best < 0\n')
					bm.write('\t\tfalsified = [falsified;1];\n')
					bm.write('\telse\n')
					bm.write('\t\tfalsified = [falsified;0];\n')
					bm.write('\tend\n')
					bm.write('\tnum_sim = [num_sim;falsif_pb.nb_obj_eval];\n')		
					bm.write('\ttime = [time;falsif_pb.time_spent];\n')
					bm.write('\tobj_best = [obj_best;falsif_pb.obj_best];\n')
	
					bm.write('end\n')

					bm.write('spec = {spec')
					n_trials = int(trials)
					for j in range(1,n_trials):
						bm.write(';spec')
					bm.write('};\n')

					bm.write('filename = {filename')
					for j in range(1,n_trials):
						bm.write(';filename')
					bm.write('};\n')
					#bm.write('base = base*ones(trials,1);\n')

					bm.write('consfile = {consfile')
					for j in range(1,n_trials):
						bm.write(';consfile')
					bm.write('};\n')
					bm.write('result = table(filename, spec, consfile , falsified, time,  obj_best, num_sim);\n')
				
					bm.write('writetable(result,\'$csv\',\'Delimiter\',\';\');\n')
					bm.write('quit\n')
					bm.write('EOF\n')
