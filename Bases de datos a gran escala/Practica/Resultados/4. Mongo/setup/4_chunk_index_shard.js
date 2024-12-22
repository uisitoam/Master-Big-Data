use tenis

db.createCollection('partidos')

db.settings.updateOne(
   { _id: "chunksize" },
   { $set: { _id: "chunksize", value: 8 } },
   { upsert: true }
)

db.partidos.createIndex({"torneo.nombre": "hashed"})
sh.shardCollection("tenis.partidos", {"torneo.nombre":"hashed"})

