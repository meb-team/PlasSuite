def give_list_id(f): 
	'''Transform file to set, where each set's elements is a line''' 
	f=open(f,"r") 
	list_id=set()
	for l in f : 
		list_id.add(l.rstrip()) 
	f.close() 
	return list_id	
