//
//  CustomChannelView.swift
//  SwiftUIChatDemo
//
//  Created by mahesh lad on 31/07/2024.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomChannelView: View {
    
    @State var channelInfoShown = false
    @State var messageDisplayInfo: MessageDisplayInfo?
    @StateObject var viewModel: ChatChannelViewModel
    
    init(channelId: ChannelId) {
        _viewModel = StateObject(wrappedValue: ChatChannelViewModel(
            channelController: InjectedValues[\.chatClient].channelController(
                for: channelId
            ))
        )
    }
    
    var body: some View {
        NavigationView {
            if let channel = viewModel.channel {
                VStack(spacing: 0) {
                    MessageListView(
                        factory: DefaultViewFactory.shared,
                        channel: channel,
                        messages: viewModel.messages,
                        messagesGroupingInfo: viewModel.messagesGroupingInfo,
                        scrolledId: $viewModel.scrolledId,
                        showScrollToLatestButton: $viewModel.showScrollToLatestButton,
                        quotedMessage: $viewModel.quotedMessage,
                        currentDateString: viewModel.currentDateString,
                        listId: viewModel.listId,
                        onMessageAppear: viewModel.handleMessageAppear(index:scrollDirection:),
                        onScrollToBottom: viewModel.scrollToLastMessage,
                        onLongPress: { displayInfo in
                            messageDisplayInfo = displayInfo
                            withAnimation {
                                viewModel.showReactionOverlay(for: AnyView(self))
                            }
                        }
                    )

                    MessageComposerView(
                        viewFactory: DefaultViewFactory.shared,
                        channelController: viewModel.channelController,
                        quotedMessage: $viewModel.quotedMessage,
                        editedMessage: $viewModel.editedMessage,
                        onMessageSent: viewModel.scrollToLastMessage
                    )
                }
                .overlay(
                    viewModel.reactionsShown ?
                        ReactionsOverlayView(
                            factory: DefaultViewFactory.shared,
                            channel: channel,
                            currentSnapshot: viewModel.currentSnapshot!,
                            messageDisplayInfo: messageDisplayInfo!,
                            onBackgroundTap: {
                                viewModel.reactionsShown = false
                                messageDisplayInfo = nil
                            }, onActionExecuted: { actionInfo in
                                viewModel.messageActionExecuted(actionInfo)
                                messageDisplayInfo = nil
                            }
                        )
                        .transition(.identity)
                        .edgesIgnoringSafeArea(.all)
                        : nil
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    DefaultChatChannelHeader(
                        channel: channel,
                        headerImage: InjectedValues[\.utils].channelHeaderLoader.image(for: channel),
                        isActive: $channelInfoShown
                    )
                }
            }
        }
    }
}
