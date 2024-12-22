db.partidos.aggregate([  
    {$match: { desenlace: "N" } },
    {$count: "partidos_con_desenlace_normal"},
]);
