FROM docker.io/nginx    
RUN yum install -y pcre-devel wget net-tools gcc zlib zlib-devel make openssl-devel    
RUN useradd -M -s /sbin/nologin nginx    
expose 80    
CMD ["nginx"]  
