SELECT  
    'Drop Trigger ' + name
FROM 
    sys.triggers  
WHERE 
    type = 'TR';