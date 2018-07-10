#Download base image ubuntu 18.04
FROM ubuntu:18.04
MAINTAINER Simone Rossi <simone.rossi.93@gmail.com>
 
ENV DEBIAN_FRONTEND noninteractive

# Update Software repository
RUN apt update
RUN apt -y install zsh wget git sudo
RUN apt -y install wget
RUN apt -y install git
RUN apt -y install sudo
RUN apt -y install lsb-core
RUN apt -y install curl
RUN apt -y install vim
RUN apt -y install tmux
RUN apt -y install tzdata 
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata

RUN chsh -s /bin/zsh

RUN useradd --create-home --shell /bin/zsh -G sudo  srossi
RUN echo "srossi:srossi" | chpasswd

RUN LAMBDA_REPO=$(mktemp) && wget -O${LAMBDA_REPO} https://lambdal.com/static/files/lambda-stack-repo.deb && \
    dpkg -i ${LAMBDA_REPO} && rm -f ${LAMBDA_REPO}
RUN apt-get update
RUN apt-get --yes upgrade

# Install DL stack
RUN apt install --yes --no-install-recommends lambda-server
RUN apt install --yes --no-install-recommends lambda-stack-cpu


# Get user configuration

USER srossi
WORKDIR /home/srossi

# Import custom VIM
COPY .vimrc /home/srossi/.vimrc
RUN vim +'silent! PlugInstall --sync' +qall 2> /dev/null


# Import custom TMUX
RUN git clone https://github.com/gpakosz/.tmux.git
RUN ln -s -f .tmux/.tmux.conf
RUN cp .tmux/.tmux.conf.local .


# Import custom ZSH
ENV SHELL /bin/zsh
RUN git clone --branch master --depth 1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
RUN cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
ENV ZSH_CUSTOM /home/srossi/.oh-my-zsh/custom 
RUN git clone https://github.com/denysdovhan/spaceship-prompt.git /home/srossi/.oh-my-zsh/custom/themes/spaceship-prompt
RUN ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
COPY .zshrc /home/srossi/.zshrc


CMD ["/bin/zsh"]
