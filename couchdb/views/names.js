function(doc) {
  emit([doc.institution, doc.name_obj.last, doc.name_obj.first], doc);
}