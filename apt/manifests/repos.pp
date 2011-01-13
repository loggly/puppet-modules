class apt::repos {
  include ::apt::repo::cloudera
  include ::apt::repo::canonical
}
