function data = load_json(jsonname)
    
    datajson = fileread(jsonname);
    data = jsondecode(datajson);

end
