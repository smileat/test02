//
//  WSViewController.m
//  IntercomDemo
//
//  Created by zsh on 2020/3/26.
//  Copyright © 2020 zsh. All rights reserved.
//

#import "WSViewController.h"
#import "CTWebSocketBaseResult.h"
#import "CTWebSocketSysScreenData.h"
#import "CTDetailButtonCell.h"
#import "CTDetailSwitchCell.h"
#import "ZSHConst.h"
static NSString *const araeTip = @"请选择系统";
static NSString *const screenTip = @"请选择屏幕";
static NSString *const detailBtnCellID = @"detailBtnCellID";
static NSString *const detailSwitchCellID = @"detailSwitchCellID";

@interface WSViewController ()<SRWebSocketDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *mainTableView;
@property (strong,nonatomic) NSMutableArray *cellDataArr;
@property (strong,nonatomic) NSTimer *heatBeat;
@property (assign,nonatomic) NSInteger reConnectCount;

@property (strong,nonatomic) MBProgressHUD *hud;

@property (strong,nonatomic) NSMutableArray *areaScreenAllDataArr;
@property (strong,nonatomic) NSMutableArray *sysNameArr;
@property (strong,nonatomic) NSMutableArray *screenNameArr;
@property (nonatomic,strong) CTWebSocketSysScreenData *sysScreenItem;
@property (nonatomic,strong) CTWebSocketClientData *deviceClientItem;

@property (nonatomic,strong) YSCVoiceWaveView *voiceWaveView;
@property (nonatomic,strong) UIView *voiceWaveParentView;
@end

@implementation WSViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self initSession];
//    [self configureBDSDK];
    [self cancelationHUD];
    [self startWebSocket];
}

#pragma mark -- SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"连接成功");
    __weak typeof(self) weakSelf = self;
    [self.hud hideAnimated:YES];
    self.hud.completionBlock = ^{
//        [SVProgressHUD showSuccessWithStatus:@"连接成功"];
//        [SVProgressHUD dismissWithDelay:0.7 completion:^{
//
//        }];
        [weakSelf initHeartBeat];
    };
}
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    NSLog(@"连接失败");
    [webSocket close];
    [self destoryHeartBeat];
    [self reConnect];
}
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    if (![MBProgressHUD HUDForView:self.view]) {
//        [SVProgressHUD showWithStatus:@"断开连接"];
    }
    [self destoryHeartBeat];
}
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSLog(@"Pong");
}
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    NSLog(@"Message = %@",message);
    CTWebSocketBaseResult *baseResult = [CTWebSocketBaseResult mj_objectWithKeyValues:message];
    if (baseResult.type == REC_MSG_TYPE_SYS_SCREEN_DATA) {
        [self.areaScreenAllDataArr removeAllObjects];
        self.areaScreenAllDataArr = [CTWebSocketSysScreenData mj_objectArrayWithKeyValuesArray:baseResult.data];
        [self.sysNameArr removeAllObjects];
        [self.areaScreenAllDataArr enumerateObjectsUsingBlock:^(CTWebSocketSysScreenData *obj, NSUInteger idx, BOOL * _Nonnull stop) {//前提条件：系统不重名
            if (![self.sysNameArr containsObject:obj.sysName]) {
                [self.sysNameArr addObject:obj.sysName];
            }
        }];
    }else if (baseResult.type == REC_MSG_TYPE_EXCHANGE_SCREEN){
        if (baseResult.result == 0) {
//            [SVProgressHUD showErrorWithStatus:@"大屏切换失败，请选其他大屏"];
        }else{
            [self openAudioQueue];
//            [SVProgressHUD showSuccessWithStatus:@"大屏切换成功"];
            [self.voiceWaveView showInParentView:self.voiceWaveParentView];
            [self.voiceWaveView startVoiceWave];
        }
    }
    else if (baseResult.type == REC_MSG_TYPE_SCREEN_ON_OR_OFF){
        CTWebSocketClientData *model = [CTWebSocketClientData mj_objectWithKeyValues:baseResult.data];
        [self replaceClientArrDataWithStatus:model];
    }
    else{
        NSLog(@"zsh == %ld",baseResult.type);
    }
}
#pragma mark -- UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CTDetailSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:detailSwitchCellID];
        [cell setCellDataScreenSwitch:self.cellDataArr[indexPath.section]];
        __typeof(self) __weak weakSelf = self;
        cell.cellSwitchBlock = ^(id obj) {
            if (indexPath.section == 0) {
                if ([obj isKindOfClass:[UISwitch class]]) {
                    [weakSelf switchControlSelect:obj];
                }
            }
        };
        return cell;
    }
    else{
        CTDetailButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:detailBtnCellID];
        [cell setCellDataSysScreen:self.cellDataArr[indexPath.section] indexPath:indexPath];
        __typeof(self) __weak weakSelf = self;
        cell.cellBtnBlock = ^(NSString *str) {
            if (indexPath.section == 1){
                [weakSelf areaNameSelect];
            }else if (indexPath.section == 2){
                [weakSelf screenNameSelect];
            }
        };
        return cell;
    }
}
#pragma mark -- Aciton
-(void)areaNameSelect{
    if (self.sysNameArr.count <= 0) {
//        [SVProgressHUD showInfoWithStatus:@"暂无数据"];
    }else{
        [self showPickerViewWithDataList:self.sysNameArr];
    }
}
-(void)screenNameSelect{
    if ([self.cellDataArr[1] isEqualToString:araeTip]) {
//        [SVProgressHUD showInfoWithStatus:@"请先选择系统"];
    }else{
        if (self.screenNameArr.count <= 0) {
//            [SVProgressHUD showInfoWithStatus:@"该系统暂无在线大屏"];
        }else{
            [self showPickerViewWithDataList:self.screenNameArr];
        }
    }
}
-(void)switchControlSelect:(UISwitch *)sw{
    if (self.socket.readyState == SR_CLOSED || self.socket.readyState == SR_CLOSING) {
//        [SVProgressHUD showErrorWithStatus:@"服务器连接失败"];
        [self resetCellDetailValue:@"0" index:0];
        return;
    }
    if (self.sysScreenItem == nil) {
//        [SVProgressHUD showInfoWithStatus:@"请选择系统"];
        [self resetCellDetailValue:@"0" index:0];
        return;
    }
    if (self.deviceClientItem == nil) {
//        [SVProgressHUD showInfoWithStatus:@"请选择大屏"];
        [self resetCellDetailValue:@"0" index:0];
        return;
    }
    [self resetCellDetailValue:sw.on?@"1":@"0" index:0];
    if (sw.on) {
        [self connectScreen];
    }else{
        AudioQueueDispose(_inputQueue, YES);
        [self.socket send:@"断开大屏"];
        [self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:^{}];
//        [SVProgressHUD dismiss];
    }
}
- (void)startWebSocket{
//    NSString *curretnToken = [[CTUser currentUser] userToken];
    self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",server_ip]]]];
    self.socket.delegate = self;
    [self.socket open];
}
-(void)closeWebSocket{
    if (self.socket.readyState == SR_OPEN||
        self.socket.readyState == SR_CONNECTING||
        self.socket.readyState == SR_CLOSING) {
        [self.socket close];
    }
    self.reConnectCount = 0;
    [self destoryHeartBeat];
    AudioQueueDispose(_inputQueue, YES);
}
- (void)cancelHUDBtnClick{
    [MBProgressHUD hideHUDForView:self.view animated:NO];
    [self resetCellDetailValue:@"0" index:0];
    [self closeWebSocket];
}
#pragma mark -- Func
-(void)connectScreen{
    NSDictionary *dic = @{@"type":@"10001",@"data":[self convertNSDictionaryToJsonString:self.deviceClientItem.mj_keyValues]};
    NSString *jsonStr = [self convertNSDictionaryToJsonString:dic];
    [self.socket send:jsonStr];
}
-(void)replaceClientArrDataWithStatus:(CTWebSocketClientData *)clientData{
    if ([self.cellDataArr.lastObject isEqualToString:clientData.clientName]) {
//        [SVProgressHUD showErrorWithStatus:@"该大屏已下线，请选择其他大屏"];
        [self resetCellDetailValue:screenTip index:2];
    }
    __typeof(self) __weak weakSelf = self;
    [self.areaScreenAllDataArr enumerateObjectsUsingBlock:^(CTWebSocketSysScreenData *sysObj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([sysObj.sysId isEqualToString:clientData.sysId]) {
            [sysObj.clientInfoList enumerateObjectsUsingBlock:^(CTWebSocketClientData *clientObj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([clientObj.clientId isEqualToString:clientData.clientId]) {
                    clientObj.deviceClientStatus.status = clientData.deviceClientStatus.status;
                    [weakSelf reorganizationClientArrData:clientData.sysName dealPushScreenData:YES];
                    *stop = YES;
                }
            }];
            *stop = YES;
        }
    }];
}
-(void)reorganizationClientArrData:(NSString *)sysName dealPushScreenData:(BOOL)isPushScreenData{
    //重组联动的大屏数据
    __typeof(self) __weak weakSelf = self;
    [self.areaScreenAllDataArr enumerateObjectsUsingBlock:^(CTWebSocketSysScreenData *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.sysName isEqualToString:sysName]) {
            if (!isPushScreenData) {
                weakSelf.sysScreenItem = obj;
            }
            [weakSelf.screenNameArr removeAllObjects];
            [obj.clientInfoList enumerateObjectsUsingBlock:^(CTWebSocketClientData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![weakSelf.screenNameArr containsObject:obj.clientName] && obj.deviceClientStatus.status == 1 && obj.deviceClientStatus != nil) {
                    [weakSelf.screenNameArr addObject:obj.clientName];
                }
            }];
            *stop = YES;
        }
    }];
}
-(void)resetCellDetailValue:(NSString *)value index:(NSInteger)index{
    [self.cellDataArr replaceObjectAtIndex:index withObject:value];
    [self.mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index]] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)initHeartBeat{
    self.heatBeat = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(sendPingData) userInfo:nil repeats:YES];
}
-(void)sendPingData{
    NSData *pingData = [@"heartBeat" dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket sendPing:pingData];
    NSLog(@"发送心跳包");
}
- (void)destoryHeartBeat{
    if (self.heatBeat) {
        [self.heatBeat invalidate];
        self.heatBeat = nil;
    }
//    [SVProgressHUD dismiss];
}
- (void)reConnect{
    if (self.reConnectCount >= 2) {
        [self closeWebSocket];
        self.hud.label.text = @"网络问题,正在取消";
        [self.hud hideAnimated:YES afterDelay:2];
        [self.voiceWaveView stopVoiceWaveWithShowLoadingViewCallback:^{
            
        }];
        return;
    }
    [self startWebSocket];
    
    if (self.reConnectCount == 0) {
        if (![MBProgressHUD HUDForView:self.view]) {
            [self cancelationHUD];
        }
        self.reConnectCount = 1;
    }else{
        self.reConnectCount += 1;
    }
}
- (NSString *)convertNSDictionaryToJsonString:(NSDictionary *)json {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"json解析失败:%@", error);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
#pragma mark -- SetupView
-(void)setupView{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.cellDataArr addObjectsFromArray:@[@"0",araeTip,screenTip]];
    [self.view addSubview:self.mainTableView];
}
- (void)cancelationHUD {
    if (![MBProgressHUD HUDForView:self.view]) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        self.hud.label.text = @"正在连接";
        [self.hud.button setTitle:@"取消" forState:UIControlStateNormal];
        [self.hud.button addTarget:self action:@selector(cancelHUDBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)dealloc{
    NSLog(@"dealloc");
    [self closeWebSocket];
}
#pragma mark -- pickerview
-(void)showPickerViewWithDataList:(NSArray *)dataList{
    if (dataList.count == 0) {
//        [SVProgressHUD showErrorWithStatus:@"暂无数据可选"];
    }else{
        __typeof(self) __weak weakSelf = self;
        [ZJPickerView zj_showWithDataList:dataList propertyDict:[self getZJPickerpropertyDict] completion:^(NSString *selectContent) {
            if (dataList == weakSelf.sysNameArr) {
                if (![weakSelf.sysScreenItem.sysName isEqualToString:selectContent]) {
                    [weakSelf resetCellDetailValue:selectContent index:1];
                    [weakSelf resetCellDetailValue:screenTip index:2];
                    weakSelf.deviceClientItem = nil;
                    [weakSelf reorganizationClientArrData:selectContent dealPushScreenData:NO];
                }
            }else if (dataList == weakSelf.screenNameArr){
                [weakSelf resetCellDetailValue:selectContent index:2];
                [weakSelf.sysScreenItem.clientInfoList enumerateObjectsUsingBlock:^(CTWebSocketClientData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.clientName isEqualToString:selectContent]) {
                        weakSelf.deviceClientItem = obj;
                        if ([weakSelf.cellDataArr.firstObject isEqualToString:@"1"]) {
                            AudioQueueDispose(weakSelf.inputQueue, YES);
                            [weakSelf connectScreen];
                        }
                        *stop = YES;
                    }
                }];
            }
        }];
    }
    
}

-(NSDictionary *)getZJPickerpropertyDict{
    NSDictionary *propertyDict = @{
                                   ZJPickerViewPropertyCanceBtnTitleKey : @"取消",
                                   ZJPickerViewPropertySureBtnTitleKey  : @"确定",
                                   ZJPickerViewPropertyCanceBtnTitleColorKey : [UIColor grayColor] ,
                                   ZJPickerViewPropertySureBtnTitleColorKey : [UIColor blueColor],
                                   ZJPickerViewPropertyLineViewBackgroundColorKey : [UIColor whiteColor],
                                   ZJPickerViewPropertyCanceBtnTitleFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertySureBtnTitleFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertyTipLabelTextFontKey : [UIFont systemFontOfSize:17.0f],
                                   ZJPickerViewPropertyPickerViewHeightKey : @200.0f,
                                   ZJPickerViewPropertyOneComponentRowHeightKey : @40.0f,
                                   ZJPickerViewPropertySelectRowTitleAttrKey : @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont systemFontOfSize:20.0f]},
                                   ZJPickerViewPropertySelectRowLineBackgroundColorKey : [UIColor blackColor],
                                   ZJPickerViewPropertyIsTouchBackgroundHideKey : @YES,
                                   ZJPickerViewPropertyIsShowTipLabelKey : @NO,
                                   ZJPickerViewPropertyIsShowSelectContentKey : @NO,
                                   ZJPickerViewPropertyIsScrollToSelectedRowKey: @YES,
                                   ZJPickerViewPropertyIsAnimationShowKey : @YES};
    return propertyDict;
}
#pragma mark -- 设置录音相关
//-(void)configureBDSDK{
//    [[BDSSpeechSynthesizer sharedInstance] setApiKey:API_KEY withSecretKey:SECRET_KEY];
//    [[BDSSpeechSynthesizer sharedInstance] setSynthParam:@(BDS_SYNTHESIZER_SPEAKER_FEMALE) forKey:BDS_SYNTHESIZER_PARAM_SPEAKER];
//}
//-(void)BDSSpeechWithSentence:(NSString *)sentence{
//    NSError* speakError = nil;
//    if([[BDSSpeechSynthesizer sharedInstance] speakSentence:sentence withError:&speakError] == -1){
//        NSLog(@"错误: %ld, %@", (long)speakError.code, speakError.localizedDescription);
//    }
//}
-(void)openAudioQueue{
    [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:kDefaultSampleRate];
    AudioQueueNewInput (&(_audioFormat),audioQueueInputCallback,(__bridge void *)self,NULL,NULL,0,&_inputQueue);
    //创建录制音频队列缓冲区
    for (int i = 0; i < kNumberAudioQueueBuffers; i++) {
        AudioQueueAllocateBuffer (_inputQueue,kDefaultInputBufferSize,&_inputBuffers[i]);
        AudioQueueEnqueueBuffer (_inputQueue,(_inputBuffers[i]),0,NULL);
    }
    //开启录制队列
    AudioQueueStart(self.inputQueue, NULL);
}
- (void)initSession{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}
//设置录音的参数
- (void)setupAudioFormat:(UInt32) inFormatID SampleRate:(int)sampeleRate{
    //重置下
    memset(&_audioFormat, 0, sizeof(_audioFormat));
    //设置格式
    _audioFormat.mFormatID = inFormatID;
    //采样率，每秒需要采集的帧数
    _audioFormat.mSampleRate = sampeleRate;
    //设置通道数
    _audioFormat.mChannelsPerFrame = 2;
    if (inFormatID == kAudioFormatLinearPCM){
        //每个通道里，一帧采集的bit数目
        _audioFormat.mBitsPerChannel = 16;
        _audioFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        //结果分析: 8bit为1byte，即为1个通道里1帧需要采集2byte数据，再*通道数，即为所有通道采集的byte数目。
        //所以这里结果赋值给每帧需要采集的byte数目，然后这里的packet也等于一帧的数据。
        //至于为什么要这样。。。不知道。。。
        _audioFormat.mBytesPerPacket = _audioFormat.mBytesPerFrame = (_audioFormat.mBitsPerChannel / 8) * _audioFormat.mChannelsPerFrame;
        _audioFormat.mFramesPerPacket = 1;
    }
}
#pragma mark -- lazy
-(UITableView *)mainTableView {
    if (_mainTableView == nil) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT) style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [_mainTableView registerClass:[CTDetailButtonCell class] forCellReuseIdentifier:detailBtnCellID];
        [_mainTableView registerClass:[CTDetailSwitchCell class] forCellReuseIdentifier:detailSwitchCellID];
        _mainTableView.scrollEnabled = NO;
        _mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kTopHeight)];
        self.voiceWaveParentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, kTopHeight)];
        _mainTableView.tableFooterView = self.voiceWaveParentView;
    }
    return _mainTableView;
}
-(NSMutableArray *)cellDataArr{
    if (_cellDataArr == nil) {
        _cellDataArr = [[NSMutableArray alloc] init];
    }
    return _cellDataArr;
}
- (YSCVoiceWaveView *)voiceWaveView{
    if (!_voiceWaveView) {
        self.voiceWaveView = [[YSCVoiceWaveView alloc] init];
    }
    return _voiceWaveView;
}
-(NSMutableArray *)areaScreenAllDataArr{
    if (_areaScreenAllDataArr == nil) {
        _areaScreenAllDataArr = [[NSMutableArray alloc] init];
    }
    return _areaScreenAllDataArr;
}
-(NSMutableArray *)sysNameArr{
    if (_sysNameArr == nil) {
        _sysNameArr = [[NSMutableArray alloc] init];
    }
    return _sysNameArr;
}
-(NSMutableArray *)screenNameArr{
    if (_screenNameArr == nil) {
        _screenNameArr = [[NSMutableArray alloc] init];
    }
    return _screenNameArr;
}

//录音回调
void audioQueueInputCallback (
                           void                                *inUserData,
                           AudioQueueRef                       inAQ,
                           AudioQueueBufferRef                 inBuffer,
                           const AudioTimeStamp                *inStartTime,
                           UInt32                              inNumberPackets,
                           const AudioStreamPacketDescription  *inPacketDescs
                           )
{
    NSLog(@"录音回调方法");
    WSViewController *rootCtrl = (__bridge WSViewController *)(inUserData);
    if (inNumberPackets > 0) {
        NSData *pcmData = [[NSData alloc] initWithBytes:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize];
        if (pcmData && pcmData.length > 0) {
            NSLog(@"录音发送");
            [rootCtrl.socket send:pcmData];
        }
    }
    AudioQueueEnqueueBuffer (inAQ,inBuffer,0,NULL);
}
@end
