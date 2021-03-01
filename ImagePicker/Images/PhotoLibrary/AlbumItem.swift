import Foundation

/**
 Элемент системного альбома фото/видео
 */
public enum AlbumItem {
    case photo(PhotoAlbumItem)
    case video(VideoAlbumItem)
}
