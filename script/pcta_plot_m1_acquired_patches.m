function axs = pcta_plot_m1_acquired_patches(did_acquire, labels, xcats, gcats, pcats)

assert_ispair( did_acquire, labels );
did_acquire = double( did_acquire );
validateattributes( did_acquire, {'double'}, {'vector'}, mfilename, 'did_acquire' );

pl = plotlabeled.make_common();
axs = pl.bar( did_acquire, labels, xcats, gcats, pcats );

end