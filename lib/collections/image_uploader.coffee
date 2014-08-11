@Images = new FS.Collection("picture",
  stores: [new FS.Store.GridFS("picture")])

@Images.allow
