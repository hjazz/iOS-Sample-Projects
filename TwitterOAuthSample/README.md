Twitter OAuth 
---
1. Twitter+OAuth 프로젝트에 추가 
1. Target - Build Phases - Link Binary with Libraries : libxml2.dylib 추가
1. Target - Build Settings - Header Search Paths : $(SDKROOT)/usr/include/libxml2 추가하고 recursive 체크
1. 트위터 연동할 뷰 컨트롤러에 SA_OAuthTwitterEngine *_engine 객체 추가
1. 발급받은 ConsumerKey, ConsumerSecret 준비
1. SA_OAuthTwitterEngine 생성. delegate 설정.
1. [_engine isAuthorized]로 인증 체크
  1. 인증이 안되어 있으면 SA_OAuthTwitterController 를 생성. 모달로 띄운다. 인증 성공후 NSUserDefaults에 authData, userName을 저장.
  1. 인증 해제시 [_engine clearAccessToken] 로 초기화. 저장된 authData, userName 삭제.
1. 인증 성공후 sendUpdate로 트위터 업로드 (delegate로 성공, 실패 처리) (이미지 업로드는 불가)


참고 : 트위터 프로필 이미지 API (SDWebImage 사용)

https://api.twitter.com/1/users/profile_image?screen_name=[username]&size=bigger

size : original, mini (24x24), normal (48x48), bigger (73x73) 원하는 크기로 요청
