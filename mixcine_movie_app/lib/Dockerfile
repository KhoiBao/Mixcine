# Mượn một con Nginx siêu nhẹ làm server
FROM nginx:alpine

# Copy toàn bộ đống HTML/JS mà bước 3 (flutter build web) vừa tạo ra vào thư mục của Nginx
COPY build/web /usr/share/nginx/html

# Mở cửa số 80
EXPOSE 80

# Chạy Nginx
CMD ["nginx", "-g", "daemon off;"]