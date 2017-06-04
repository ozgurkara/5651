# 5651 SAYILI KANUN
5651 Sayılı kanun kapsamında sunucularınıza gelen requestlerin hangi IP ile ne zaman request atıldığıyla ilgili logların zaman damgası vurulup 3 yıl boyunca saklanması gerekir.

Bu projedeki log_helper.sh scripti parametre olarak gönderilen log dosyasını; \n
1-kamuasm.gov.tr servisine göndererek zaman damgası dosyası oluşturulur.
2-Oluşan zaman dosyası ve log dosyası ziplenip.
3-Oluşturulan bu zip formatındaki dosya Azure Storage a upload edilir.
3-Storage a gönderilen dosya boyutu ve zaman damgası için kalan kredi Slack te ile istenilen channel a notification ile bildirilir.
