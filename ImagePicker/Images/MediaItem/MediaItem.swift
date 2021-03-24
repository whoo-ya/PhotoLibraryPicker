import Foundation

/**
 Обработанный элемент альбома (кропнутый, отцентрированный и тд.) для сохранения на устройстве. Включает оригинальные данные.
 */
public enum MediaItem {
    
    /**
     Фото элемент
     */
    case photo(item: MediaPhotoItem)
    
    /**
     Видео элемент
     */
    case video(item: MediaVideoItem)
}
